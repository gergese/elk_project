function Test-Role {
  Param([Security.Principal.WindowsBuiltinRole]$Role )
  $CurrentUser = [Security.Principal.WindowsPrincipal]([Security.Principal.WindowsIdentity]::GetCurrent())
  $CurrentUser.IsInRole($Role)
}

# 공백 / 줄바꿈이 존재하는 object형 결과값을 공백없는 String형 결과값으로 바꿔주는 함
function String([object]$string) {
  $string_return = Out-String -InputObject $string
  $string_return = $string_return.Split(" ")[0]
  $string_return = $string_return.Split("`r")[2]
  $string_return = $string_return.Split("`n")[1]

  return $string_return
}

# 경로의 권한을 얻어온다.
function Get-Permissions($Path) {
    (Get-Acl -Path $Path).Access | select 
  @{Label = "identity"; Expression = { $_.IdentityReference } }
}

# 레지스트리 키 이름, 타입, 값을 출력해준다.
function Get-RegistryValue {
  param
  (
    [Parameter(Mandatory = $true)]
    $RegistryKey
  )

  $key = Get-Item -Path "Registry::$RegistryKey"
  $key.GetValueNames() |
  ForEach-Object {
    $name = $_
    $rv = 1 | Select-Object -Property Name, Type, Value
    $rv.Name = $name
    $rv.Type = $key.GetValueKind($name)
    $rv.Value = $key.GetValue($name)
    $rv
  
  }
}

# 입력된 경로의 레지스트리 키가 존재하는지 확인한다.
function Test-RegistryValue($regkey, $name) {
  try {
    $exists = Get-ItemProperty $regkey $name -ErrorAction SilentlyContinue
    if (($exists -eq $null) -or ($exists.Length -eq 0)) {
      return $false
    }
    else {
      return $true
    }
  }
  catch {
    return $false
  }
}

#SID를 계정이름으로 변경해준다.
function Convert_SID_TO_USERNAME($SID) {
  $objSID = New-Object System.Security.Principal.SecurityIdentifier($SID)
  $objUser = $objSID.Translate( [System.Security.Principal.NTAccount])
  return ($objUser.Value)
}

# 사용자 권한 템플릿 파일 경로
$securityTemplatePath = ".\user_rights.inf"
$databasePath = ".\secedit.sdb"

$index = 0
$root_title = "보안 관리"
$title = 0
$result = 0

#################################################### < 5 . 보안 관리 > ####################################################
#############################################################################################################################

########### 37. SAM 파일 접근 통제 설정 ###########

$index = "37"
$title = "SAM 파일 접근 통제 설정"

$RV = "SAM 파일 접근 권한에 Administrator , System 그룹만 모든 권한으로 설정되어 있는 경우"
$importance = "상"

# 경로 설정
$path = "C:\Windows\System32\config\SAM"

# 현재 ACL 가져오기
$acl = Get-Acl -Path $path

# 제거할 권한 필터링: System과 Administrator를 제외한 모든 권한
$rulesToRemove = $acl.Access | Where-Object { 
  $_.IdentityReference -ne "SYSTEM" -and $_.IdentityReference -ne "Administrators"
}

# 제거할 권한이 있을 경우
if ($rulesToRemove) {
  foreach ($rule in $rulesToRemove) {
    # ACL에서 권한 제거
    $acl.RemoveAccessRule($rule)
  }
  # 수정된 ACL을 다시 설정
  Set-Acl -Path $path -AclObject $acl
}

Write-Host ($index + "#" + $root_title + + "#" + $title + "#" + "불필요한 권한 제거") >> action_result.txt

###############################################

########### 38. 화면보호기 설정 ###########

$index = "38"
$title = "화면보호기 설정"

$RV = "화면 보호기 설정 & 대기 시간 10분 이하 값 & 화면 보호기 해제를 위한 암호 사용 시"
$importance = "상"

# 레지스트리 경로 설정
$regPath = "HKCU\Control Panel\Desktop"

# Timeout 설정 (10분 = 600초)
$TimeoutValue = 600
Set-ItemProperty -Path $regPath -Name "ScreenSaveTimeOut" -Value $TimeoutValue

# Secure 설정 (1로 설정)
$SecureValue = 1
Set-ItemProperty -Path $regPath -Name "ScreenSaveActive" -Value $SecureValue

# Lock 설정 (1로 설정)
$LockValue = 1
Set-ItemProperty -Path $regPath -Name "ScreenSaverIsSecure" -Value $LockValue

Write-Host ($index + "#" + $root_title + + "#" + $title + "#" + "화면 보호기 설정. 재부팅 필요") >> action_result.txt

###############################################

########### 39. 로그온 하지 않고 시스템 종료 허용 해제 ###########

$index = "39"
$title = "로그온 하지 않고 시스템 종료 허용 해제"

$RV = "'사용 안함' 옵션으로 설정"
$importance = "상"

# 레지스트리 경로 설정
$regPath = "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$keyName = "shutdownwithoutlogon"

# 값이 0으로 설정
Set-ItemProperty -Path $regPath -Name $keyName -Value 0

# 설정 결과 출력
$updatedValue = (Get-RegistryValue $regPath | Where-Object { $_.Name -eq $keyName }).Value

Write-Host ($index + "#" + $root_title + + "#" + $title + "#" + "로그온 하지 안호 시스템 종료 허용 해제 설정") >> action_result.txt

###############################################

########### 40. 원격 시스템에서 강제로 시스템 종료 ###########

$index = "40"
$title = "원격 시스템에서 강제로 시스템 종료"

$RV = "해당 정책에 'Administrator'만 존재하는 경우"
$importance = "상"

SecEdit /export /cfg $securityTemplatePath

# 파일 내용 전체를 가져옵니다.
$fileContent = Get-Content $securityTemplatePath

# SeRemoteShutdownPrivilege 항목을 수정하여 Administrator만 포함하도록 합니다.
$fileContent = $fileContent -replace "SeRemoteShutdownPrivilege\s*=\s*.*", "SeRemoteShutdownPrivilege = *S-1-5-32-544"  # S-1-5-32-544는 Administrator SID입니다.

# 수정된 내용을 파일에 다시 저장합니다.
Set-Content -Path $securityTemplatePath -Value $fileContent

Write-Host ($index + "#" + $root_title + + "#" + $title + "#" + "SeRemoteShutdownPrivilege 값 Administrator로 변경") >> action_result.txt

# 보안 템플릿 임포트
secedit /configure /db $databasePath /cfg $securityTemplatePath

SecEdit /export /cfg $securityTemplatePath

###############################################

########### 41. 보안 감사를 로그할 수 없는 경우 즉시 시스템 종료 해제 ###########

$index = "41"
$title = "보안 감사를 로그할 수 없는 경우 즉시 시스템 종료 해제"

$RV = "해당 정책을 사용 하지 않을 경우"
$importance = "상"

# 레지스트리 경로 및 키 설정
$regPath = "HKLM\SYSTEM\CurrentControlSet\Control\Lsa"
$keyName = "crashonauditfail"
$newValue = 0

# 현재 값 확인
$currentValue = Get-ItemProperty -Path $regPath -Name $keyName -ErrorAction SilentlyContinue

if ($currentValue) {
  # 값이 존재하면 0으로 설정
  Set-ItemProperty -Path $regPath -Name $keyName -Value $newValue
}
else {
  # 값이 없으면 추가
  New-ItemProperty -Path $regPath -Name $keyName -Value $newValue -PropertyType DWord
}

Write-Host ($index + "#" + $root_title + + "#" + $title + "#" + "crashonauditfail값 0으로 설정") >> action_result.txt

###############################################

########### 42. SAM 계정과 공유의 익명 열거 허용 안 함 ###########

$index = "42"
$title = "SAM 계정과 공유의 익명 열거 허용 안 함"

$RV = "해당 정책을 사용하지 않을 경우"
$importance = "상"

# 레지스트리 경로 설정
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"

# 레지스트리 키 이름
$keyNames = @("restrictanonymous", "restrictanonymoussam")

# 값 설정
$newValue = 1

foreach ($keyName in $keyNames) {
  # 현재 값 확인
  $currentValue = Get-ItemProperty -Path $regPath -Name $keyName -ErrorAction SilentlyContinue

  if ($currentValue) {
    # 값이 존재하면 1로 설정
    Set-ItemProperty -Path $regPath -Name $keyName -Value $newValue
  }
  else {
    # 값이 없으면 새로 추가
    New-ItemProperty -Path $regPath -Name $keyName -Value $newValue -PropertyType DWord
  }
}

Write-Host ($index + "#" + $root_title + + "#" + $title + "#" + "restrictanonymous, restrictanonymoussam 값 1로 설정") >> action_result.txt

###############################################

########### 43. Autologin 기능 제어 ###########

$index = "43"
$title = "Autologin 기능 제어"

$RV = "AutoAdminLogon 값이 없거나 0으로 설정되어 있는 경우"
$importance = "상"

# 레지스트리 경로 설정
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
$keyName = "AutoAdminLogon"

# 현재 값 확인
$currentValue = Get-ItemProperty -Path $regPath -Name $keyName -ErrorAction SilentlyContinue

if ($currentValue) {
    # 값이 존재하면 0으로 설정
    Set-ItemProperty -Path $regPath -Name $keyName -Value 0
}

Write-Host ($index + "#" + $root_title + + "#" + $title + "#" + "AutoAdminLogon 값 0으로 설정") >> action_result.txt

###############################################

########### 44.이동식 미디어 포맷 및 꺼내기 허용 ###########

$index = "44"
$title = "이동식 미디어 포맷 및 꺼내기 허용"

$RV = "해당 옵션 정책이 'Administrator' 로 설정되어 있는 경우"
$importance = "상"

# 레지스트리 경로 설정
$regPath = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon"
$keyName = "AllocateDASD"

# 현재 값 확인
$currentValue = Get-ItemProperty -Path $regPath -Name $keyName -ErrorAction SilentlyContinue

if ($currentValue) {
    # 값이 존재하면 0으로 설정
    Set-ItemProperty -Path $regPath -Name $keyName -Value 0
}

Write-Host ($index + "#" + $root_title + + "#" + $title + "#" + "AllocateDASD 값 0으로 설정") >> action_result.txt

###############################################

########### 72. DoS 공격 방어 레지스트리 설정 ###########

$index = "72"
$title = "DoS 공격 방어 레지스트리 설정"

$RV = "DoS 방어 레지스트리 값을 적절하게 설정"
$importance = "중"

# 레지스트리 경로 설정
$regPath = "HKLM:\System\CurrentControlSet\Services\Tcpip\Parameters"

# 레지스트리 값 설정 함수
function Set-RegistryValue {
    param (
        [string]$Path,
        [string]$Name,
        [int]$Value
    )

    $currentValue = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
    if ($currentValue) {
        # 값이 존재하면 해당 값으로 설정
        Set-ItemProperty -Path $Path -Name $Name -Value $Value
    } else {
        # 값이 없으면 새로 추가
        New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType DWord
    }
}

# 각각의 값을 설정
Set-RegistryValue -Path $regPath -Name "SynAttackProtect" -Value 1
Set-RegistryValue -Path $regPath -Name "EnableDeadGWDetect" -Value 0
Set-RegistryValue -Path $regPath -Name "KeepAliveTime" -Value 300000
Set-RegistryValue -Path $regPath -Name "NoNameReleaseOnDemand" -Value 1

Write-Host ($index + "#" + $root_title + + "#" + $title + "#" + "SynAttackProtect 값 1, EnableDeadGWDetect 값 0, KeepAliveTime 값 300000, NoNameReleaseOnDemand 값 1로 설정") >> action_result.txt

###############################################

########### 73. 사용자가 프린터 드라이버를 설치할 수 없게 함 ###########

$index = "73"
$title = "사용자가 프린터 드라이버를 설치할 수 없게 함"

$RV = "해당 정책을 사용 하는 경우"
$importance = "중"

$flag = (Get-RegistryValue "HKLM\SYSTEM\CurrentControlSet\Control\Print\Providers\LanMan Print Services\Servers" | Where-Object { $_.Name -eq "AddPrinterDrivers" }).Value
    
# 레지스트리 경로 설정
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Print\Providers\LanMan Print Services\Servers"
$keyName = "AddPrinterDrivers"

# 현재 값 확인
$currentValue = Get-ItemProperty -Path $regPath -Name $keyName -ErrorAction SilentlyContinue

if ($currentValue) {
    # 값이 존재하면 1로 설정
    Set-ItemProperty -Path $regPath -Name $keyName -Value 1
}

Write-Host ($index + "#" + $root_title + + "#" + $title + "#" + "AddPrinterDrivers 값 1로 설정") >> action_result.txt

###############################################

########### 74. 세션 연결을 중단하기 전에 필요한 유휴시간 ###########

$index = "74"
$title = "세션 연결을 중단하기 전에 필요한 유휴시간"

$tempSTR = @(0, 0)

$RV = "'로그온 시간이 만료되면 클라이언트 연결 끊기 정책' 사용 & '세션 연결을 중단하기 전에 필요한 유휴시간 15분' 설정"
$importance = "중"

# 레지스트리 경로 설정
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters"
$keyName = "enableforcedlogoff"
$keyName2 = "autodisconnect"

# 현재 값 확인
$currentValue_active = Get-ItemProperty -Path $regPath -Name $keyName -ErrorAction SilentlyContinue
$currentValue_time = Get-ItemProperty -Path $regPath -Name $keyName2 -ErrorAction SilentlyContinue

if ($currentValue_active) {
    # 값이 존재하면 1로 설정
    Set-ItemProperty -Path $regPath -Name $keyName -Value 1
}

if ($currentValue_time) {
  # 값이 존재하면 15분으로 설정
  Set-ItemProperty -Path $regPath -Name $keyName2 -Value 15
}

Write-Host ($index + "#" + $root_title + + "#" + $title + "#" + "enableforcedlogoff 값 1, autodisconnect 값 15로 설정") >> action_result.txt

###############################################

########### 75. 경고 메세지 설정 ###########

$index = "75"
$title = "경고 메세지 설정"

$RV = "로그인 경고 메세지 제목 및 내용이 설정되어 있는 경우"
$importance = "하"

$tempSTR = @(0, 0)

$flag_title = (Get-RegistryValue "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" | Where-Object { $_.Name -eq "legalnoticecaption" }).Value
$flag_text = (Get-RegistryValue "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" | Where-Object { $_.Name -eq "legalnoticetext" }).Value

if ($flag_title.length -eq 0) {
  $result = "취약"
  $tempSTR[0] = "로그인 경고 제목이 설정되어 있지 않습니다."
}
else {
  if ($flag_text.length -eq 0 -or $flag_text -eq '') {
    $result = "취약"
    $tempSTR[1] = "로그인 경고 내용이 설정되어 있지 않습니다."
  }
  else {
    $result = "양호"
    $tempSTR[0] = "설정된 로그인 경고 제목은 '" + $flag_title + "' 입니다."
    $tempSTR[1] = "설정된 로그인 경고 내용은 '" + $flag_text + "' 입니다."
  }
}


$CV = $tempSTR[0] + $tempSTR[1]

echo($index + "#" + $root_title + "#" + $title + "#" + $result) >> check_result.txt

echo($index + '#' + $root_title + '#' + $title + '#' + $RV + '#' + $CV + '#' + $result + '#' + $importance) >> check_result_more.txt

###############################################

########### 76. 사용자별 홈 디렉토리 권한 설정 ###########

$index = "76"
$title = "사용자별 홈 디렉토리 권한 설정"

$RV = "홈 디렉토리에 Everyone 권한이 없는 경우"
$importance = "중"

$tempSTR = @()
$total_count = 0

$User_List = (Get-Localuser).Name
$User_Home_DIR = @()

foreach ($user_item in $User_List) {
  $User_Home_DIR += 'C:\Users\' + $user_item
}

for ($X = 0; $X -lt $User_Home_DIR.Count; $X++) {
  $flag = Test-Path -Path $User_Home_DIR[$X]

  if ($flag) {
    $Everyone_Access_count = (Get-Permissions -Path $User_Home_DIR[$X] | Where-Object { $_.IdentityReference -like "*Everyone*" }).Count
    if ($Everyone_Access_count -gt 0) {
      $tempSTR += $User_List[$X]
      $tempSTR += ','

      $total_count++
    }
  }
}

if ($tempSTR.count -gt 0) {
  $tempSTR[-1] = ''
}

if ($total_count -gt 0) {
  $result = "취약"
  $CV = $tempSTR + "사용자 홈 디렉토리에서 Everyone 권한 존재"
}
else {
  $result = "양호"
  $CV = "홈 디렉토리에 Everyone 권한을 가진 사용자는 존재X"
}

echo($index + "#" + $root_title + "#" + $title + "#" + $result) >> check_result.txt

echo($index + '#' + $root_title + '#' + $title + '#' + $RV + '#' + $CV + '#' + $result + '#' + $importance) >> check_result_more.txt

###############################################

########### 77. LAN Manager 인증 수준 ###########

$index = "77"
$title = "LAN Manager 인증 수준"

$RV = "인증 수준을 'NTLMv2 응답만 보냄' 으로 설정"
$importance = "중"

$flag = (Get-RegistryValue "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" | Where-Object { $_.Name -eq "LmComPatibilityLevel" }).Value
if ($flag) {
  if ($flag -ge 3) {
    $result = "양호"
    $CV = "현재 LAN Manager 인증 수준은 'NTLMv2' 입니다."
  }
  else {
    $result = "취약"

    switch ($flag) {
      0 { $CV = "현재 LAN Manager 인증 수준은 'NTLMv2' 입니다." }
      1 { $CV = "현재 LAN Manager 인증 수준은 'LM 및 NTLM 응답 보내기 - 협상되면 NTLMv2 세션 보안 사용'" }
      2 { $CV = "현재 LAN Manager 인증 수준은 'NTLM 응답만 보내기' 입니다." }
      # 4 {$CV = "현재 LAN Manager 인증 수준은 'NTLMv2 응답만 보내기 및 LM 거부' 입니다."}
      # 5 {$CV = "현재 LAN Manager 인증 수준은 'NTLMv2 응답만 보냅니다. LM 및 NTLM은 거부합니다.'"}
      default {}
    }
  }
}
else {
  $result = "취약"
  $CV = "LAN Manager 인증 수준을 설정하지 않았습니다."
}

echo($index + "#" + $root_title + "#" + $title + "#" + $result) >> check_result.txt

echo($index + '#' + $root_title + '#' + $title + '#' + $RV + '#' + $CV + '#' + $result + '#' + $importance) >> check_result_more.txt

###############################################

########### 78. 보안 채널 데이터 디지털 암호화 또는 서명 ###########

$index = "78"
$title = "보안 채널 데이터 디지털 암호화 또는 서명"

$RV = "도메인 구성원 정책 중 '보안 채널 데이터를 디지털 암호화 또는, 서명' / '보안 채널 데이터 디지털 암호화(가능한 경우)' / '보안 채널 데이터 서명(가능한 경우)' 정책이 '사용' 상태인 경우"
$importance = "중"

$tempSTR = @()

$flag_1 = (Get-RegistryValue "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" | Where-Object { $_.Name -eq "RequireSignOrSeal" }).Value
$flag_2 = (Get-RegistryValue "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" | Where-Object { $_.Name -eq "SealSecureChannel" }).Value
$flag_3 = (Get-RegistryValue "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" | Where-Object { $_.Name -eq "SignSecureChannel" }).Value

if ($flag_1 -eq 1 -and $flag_2 -eq 1 -and $flag_3 -eq 1) {
  $result = "양호"
  $CV = "3가지 정책 모두 사용 중"
}
else {
  if ($flag_1 -eq 0) {
    $result = "취약"
    $tempSTR += "'보안 채널 데이터를 디지털 암호화 또는, 서명' 정책"
    $tempSTR += ','
  }
  if ($flag_1 -eq 0) {
    $result = "취약"
    $tempSTR += "'보안 채널 데이터 디지털 암호화' 정책"
    $tempSTR += ','
  }
  if ($flag_1 -eq 0) {
    $result = "취약"
    $tempSTR += "'보안 채널 데이터 서명' 정책"
    $tempSTR += ','
  }

  if ($tempSTR.count -gt 0) {
    $tempSTR[-1] = ''
  }

  $CV = $tempSTR + "을 사용하고 있지 않습니다."
}

echo($index + "#" + $root_title + "#" + $title + "#" + $result) >> check_result.txt

echo($index + '#' + $root_title + '#' + $title + '#' + $RV + '#' + $CV + '#' + $result + '#' + $importance) >> check_result_more.txt

###############################################

########### 79. 파일 및 디렉토리 보호 ###########

$index = "79"
$title = "파일 및 디렉토리 보호"

$RV = "NTFS 파일 시스템을 사용"
$importance = "중"

$tempSTR = @()

$Not_NTFS_Count = @(Get-Volume | Where-Object { $_.OperationalStatus -eq "OK" } | Where-Object { $_.DriveLetter } | Where-object { ($_.FileSystemType -eq "NTFS") -and ($_.FileSystemType -eq "Unknown") }).Count

if ($Not_NTFS_Count -gt 0) {
  $result = "양호"
    
  $Not_NTFS_list = (Get-Volume | Where-Object { $_.OperationalStatus -eq "OK" } | Where-Object { $_.DriveLetter }).DriveLetter | Where-object { $_.FileSystem -ne "NTFS" }
    
  foreach ($item in $Not_NTFS_list) {
    $tempSTR += $item
    $tempSTR += ','
  }

  if ($tempSTR.count -gt 0) {
    $tempSTR[-1] = ''
  }

  $CV = "NTFS 파일 시스템을 사용하지 않는 드라이브는 " + $tempSTR + " 드라이브 입니다."
}
else {
  $result = "양호"
  $CV = "활성화된 드라이브중 NTFS 파일 시스템을 사용하지 않는 드라이브는 없습니다."
}

echo($index + "#" + $root_title + "#" + $title + "#" + $result) >> check_result.txt

echo($index + '#' + $root_title + '#' + $title + '#' + $RV + '#' + $CV + '#' + $result + '#' + $importance) >> check_result_more.txt

###############################################

########### 80. 컴퓨터 계정 암호 최대 사용 기간 ###########

$index = "80"
$title = "컴퓨터 계정 암호 최대 사용 기간"

$RV = "'컴퓨터 계정 암호 변경 사용 안 함' 정책을 사용하지 않으며, '컴퓨터 계정 암호 최대 사용기간'이 90일로 설정"
$importance = "중"

$CV = @()

$flag_1 = (Get-RegistryValue "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" | Where-Object { $_.Name -eq "DisablePasswordChange" }).Value
$flag_2 = (Get-RegistryValue "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" | Where-Object { $_.Name -eq "MaximumPasswordAge" }).Value

if ($flag_1 -eq 0) {
  $result = "양호"
  $CV += "'컴퓨터 계정 암호 변경 사용 안 함' 정책을 사용하지 않으며, "
}
else {
  $result = "취약"
  $CV += "'컴퓨터 계정 암호 변경 사용 안 함' 정책을 사용하며, "
}

if ($flag_2 -le 90) {
  $CV += "컴퓨터 계정 암호 최대 사용 기간이 " + $flag_2.toString() + "일로 설정"
}
else {
  $result = "취약"
  $CV += "컴퓨터 계정 암호 최대 사용 기간이 " + $flag_2.toString() + "일로 설정"
}


echo($index + "#" + $root_title + "#" + $title + "#" + $result) >> check_result.txt

echo($index + '#' + $root_title + '#' + $title + '#' + $RV + '#' + $CV + '#' + $result + '#' + $importance) >> check_result_more.txt

###############################################

########### 81. 시작프로그램 목록 분석 ###########

$index = "81"
$title = "시작프로그램 목록 분석"

$RV = "시작 프로그램을 정기적으로 검사한다."
$importance = "중"

$Start_program_count = (Get-RegistryValue "hkcu\Software\Microsoft\Windows\CurrentVersion\Run" | Select-Object Name, Value | Format-List).count

if ($Start_program_count -eq 0) {
  $result = "양호"
  $CV = "등록된 시작 프로그램이 존재하지 않습니다."
}
else {
  $result = "수동"
  echo("--------------- 시작 프로그램 목록 ---------------") > 81_Start_Program_List.txt
  Get-RegistryValue "hkcu\Software\Microsoft\Windows\CurrentVersion\Run" | Select-Object Name, Value | Format-List >> 81_Start_Program_List.txt

  $CV = "수동 확인"

}

echo($index + "#" + $root_title + "#" + $title + "#" + $result) >> check_result.txt

echo($index + '#' + $root_title + '#' + $title + '#' + $RV + '#' + $CV + '#' + $result + '#' + $importance) >> check_result_more.txt

###############################################

########### 82. Windows 인증 모드 사용 ###########

$index = "82"
$title = "Windows 인증 모드 사용"
$result = "수동"

$RV = "DB 로그인 시, Windos 인증 모드 사용 / sa 계정 비 활성화 / sa 계정 사용시 강력한 암호정책 사용"
$importance = "중"

$CV = "수동 점검"

#HKEY_LOCAL_MACHINE\Software\Microsoft\Microsoft SQL Server\<Instance Name>\MSSQLServer\LoginMode
# 1 : Windwos 인증만
# 2 : 혼합 모드 인증

echo($index + "#" + $root_title + "#" + $title + "#" + $result) >> check_result.txt

echo($index + '#' + $root_title + '#' + $title + '#' + $RV + '#' + $CV + '#' + $result + '#' + $importance) >> check_result_more.txt

###############################################

#############################################################################################################################