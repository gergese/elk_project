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

#################### FTP 사이트 이름과 경로는 자주 점검에 자주 사용되므로 미리 구해둔다. ####################

$FTP_Site_List = Get-IISSite | Where-Object { $_.Bindings -like "*ftp*" } | select-Object Name

$FTP_Site_Name_list = @()
$FTP_Site_Path_list = @()
$FTP_Site_Path_Full_Path_list = @()

foreach ($name_item in $FTP_Site_List) {
  $name_item = $name_item | Format-Wide

  # 공백 , newline 문자열을 버리고 이름만 추출
  $Site_Name = String $name_item
  $FTP_Site_Name_list += $Site_Name

  $Site_Path = 'IIS:\Sites\' + $Site_Name
  $FTP_Site_Path_list += $Site_Path

  # 드라이브 이름으로 시작하는 (EX : C\..) 실제 경로
  $Site_Path = (Get-WebFilePath $Site_Path).FullName
  $FTP_Site_Path_Full_Path_list += $Site_Path

}

#############################################################################################################


$index = 0
$root_title = "로그 관리"
$title = 0
$result = 0

#################################################### < 4 . 로그 관리 > ####################################################
#############################################################################################################################

###############################################

########### 35. 원격으로 액세스 할 수 있는 레지스트리 경로 ###########

$index = "35"
$title = "원격으로 액세스 할 수 있는 레지스트리 경로"

$RV = "RemoteRegistry Service를 사용하지 않는 경우"
$importance = "상"

# RemoteRegistry 서비스 가져오기
$service = Get-Service -Name "RemoteRegistry"

# 서비스 중지
if ($service.Status -eq 'Running') {
  Stop-Service -Name "RemoteRegistry" -Force
}

# 서비스 시작 유형을 '사용 안 함'으로 설정
Set-Service -Name "RemoteRegistry" -StartupType Disabled

$CV = "RemoteRegistry '사용 안 함'으로 설정"
Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV
# Write-Host ($index + "#" + $root_title + + "#" + $title + "#" + "RemoteRegistry '사용 안 함'으로 설정") >> action_result.txt

###############################################

########### 70. 이벤트 로그 관리 설정 ###########

$index = "70"
$title = "이벤트 로그 관리 설정"

$RV = "최대 로그 크기 10,240KB 이상 & '90일 이후 이벤트 덮어 씀' 설정" 
$importance = "하"
$CV = ""

# 응용 프로그램 로그 설정
# 레지스트리 경로 설정
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\Application"

# 보존 설정을 0으로 변경
Set-ItemProperty -Path $regPath -Name "Retention" -Value 0

# 최대 로그 크기를 10240KB (10MB)로 설정
$maxSizeKB = 10240
$maxSizeBytes = $maxSizeKB * 1KB # KB를 바이트로 변환

Set-ItemProperty -Path $regPath -Name "MaxSize" -Value $maxSizeBytes

# 보안 관련 로그 설정
# 레지스트리 경로 설정
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\Security"

# 보존 설정을 0으로 변경
Set-ItemProperty -Path $regPath -Name "Retention" -Value 0

# 최대 로그 크기를 10240KB (10MB)로 설정
$maxSizeKB = 10240
$maxSizeBytes = $maxSizeKB * 1KB # KB를 바이트로 변환

Set-ItemProperty -Path $regPath -Name "MaxSize" -Value $maxSizeBytes

# 시스템 관련 로그 설정
# 레지스트리 경로 설정
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\System"

# 보존 설정을 0으로 변경
Set-ItemProperty -Path $regPath -Name "Retention" -Value 0

# 최대 로그 크기를 10240KB (10MB)로 설정
$maxSizeKB = 10240
$maxSizeBytes = $maxSizeKB * 1KB # KB를 바이트로 변환

Set-ItemProperty -Path $regPath -Name "MaxSize" -Value $maxSizeBytes

$CV = "RemoteRegistry '사용 안 함'으로 설정"
Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV
# Write-Host ($index + "#" + $root_title + + "#" + $title + "#" + "이벤트 로그의 보존 설정을 0, 최대 크기를 10MB로 설정") >> action_result.txt

###############################################

########### 71. 원격에서 이벤트 로그 파일 접근 차단 ###########

$index = "71"
$title = "원격에서 이벤트 로그 파일 접근 차단"

$RV = "로그 디렉토리의 접근 권한에 Everyone 권한이 없는 경우"
$importance = "중"

# 경로 목록
$paths = @("C:\Windows\System32\config", "C:\Windows\System32\LogFiles")

foreach ($path in $paths) {
  # ACL 가져오기
  $acl = Get-Acl -Path $path
    
  # Everyone 권한 필터링
  $everyoneAccessRules = $acl.Access | Where-Object { $_.IdentityReference -like "*Everyone*" }

  # Everyone 권한이 있는 경우
  if ($everyoneAccessRules) {
    foreach ($rule in $everyoneAccessRules) {
      # ACL에서 권한 제거
      $acl.RemoveAccessRule($rule)
    }
    # 수정된 ACL을 다시 설정
    Set-Acl -Path $path -AclObject $acl
  }
}

$CV = "RemoteRegistry '사용 안 함'으로 설정"
Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV
# Write-Host ($index + "#" + $root_title + + "#" + $title + "#" + "'Everyone' 권한 제거") >> action_result.txt
       
###############################################

#############################################################################################################################