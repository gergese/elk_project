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

#############################################################################################################

#################### IIS 사이트 이름과 경로는 자주 점검에 자주 사용되므로 미리 구해둔다. ####################

$IIS_Site_List = Get-IISSite | select-Object Name

$Site_Name_list = @()
$Site_Path_list = @()
$Site_Path_Full_Path_list = @()

foreach ($name_item in $IIS_Site_List) {
  $name_item = $name_item | Format-Wide

  # 공백 , newline 문자열을 버리고 이름만 추출
  $Site_Name = String $name_item
  $Site_Name_list += $Site_Name

  $Site_Path = 'IIS:\Sites\' + $Site_Name
  $Site_Path_list += $Site_Path

  # 드라이브 이름으로 시작하는 (EX : C\..) 실제 경로
  $Site_Path = (Get-WebFilePath $Site_Path).FullName
  $Site_Path_Full_Path_list += $Site_Path

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
$root_title = "서비스 관리"
$title = 0
$result = 0

########### 26. FTP 디렉토리 접근권한 설정 ###########

$index = "26"
$title = "FTP 디렉토리 접근권한 설정"

$RV = "FTP 홈 디렉토리에 Everyone 권한이 없는 경우"
$importance = "상"

for ($X = 0; $X -lt $FTP_Site_Name_list.count; $X++) {
  # FTP 사이트 경로
  $currentPath = $FTP_Site_Path_Full_Path_list[$X]
        
  # 파일 및 디렉터리의 현재 권한을 가져옴
  $acl = Get-Acl -Path $currentPath
        
  # Everyone 권한이 있는 항목을 필터링
  $acl.Access | Where-Object { $_.IdentityReference -like "*Everyone*" } | ForEach-Object {

    # Everyone 권한을 제거
    $acl.RemoveAccessRule($_)
            
    # 변경된 ACL을 해당 경로에 다시 설정
    Set-Acl -Path $currentPath -AclObject $acl
  }
}

$CV = "Everyone 권한 제거"
Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV
# Write-Host ($index + "#" + $root_title + + "#" + $title + "#" + "Everyone 권한 제거") >> action_result.txt

###############################################

########### 27. Anonymous FTP 금지 ###########


$index = "27"
$title = "Anonymous FTP 금지"

$RV = "FTP 서비스 사용X or 익명 연결 허용 옵션을 해제"
$importance = "상"

if ($FTP_Site_List.length -ne 0) {
  for ($X = 0; $X -lt $FTP_Site_Name_list.count; $X++) {
    $Web_Property_Filter = "/system.webServer/security/authentication/anonymousAuthentication"
    Set-WebConfigurationProperty -Filter $Web_Property_Filter -PSPath $FTP_Site_Path_list[$X] -Name enabled -Value $false
  }
  $CV = "익명 연결 허용 x"
  Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV
  # Write-Host ($index + "#" + $root_title + + "#" + $title + "#" + "익명 연결 허용 x") >> action_result.txt
}

###############################################

########### 28. FTP 접근 제어 설정 ###########


$index = "28"
$title = "FTP 접근 제어 설정"

$importance = "상"

for ($X = 0; $X -lt $FTP_Site_Name_list.count; $X++) {
  $Web_Property_Filter = "/system.ftpserver/security/ipsecurity"

  Set-WebConfigurationProperty -Filter $Web_Property_Filter -PSPath $FTP_Site_Path -Name "allowUnlisted" -Value $false
}

$CV = "접근제어 설정 적용"
Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV
# Write-Host ($index + "#" + $root_title + + "#" + $title + "#" + "접근제어 설정 적용") >> action_result.txt

###############################################

########### 29. DNS Zone Transfer 설정 ###########


$index = "29"
$title = " DNS Zone Transfer 설정"

$RV = "DNS 서비스 사용X / 영역 전송 허용X / 특정 서버로만 설정"
$importance = "상"

$CV = "DNS 사용 여부에 맞게 수정해 주세요"
Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV
# Write-Host ($index + "#" + $root_title + + "#" + $title + "#" + "DNS 사용 여부에 맞게 수정해 주세요") >> action_result.txt

###############################################

# 특정 DNS 도메인 상세 확인
#Get-DnsServerZone -ZoneName 0.in-addr.arpa | Format-List

# 특정 도메인 영역 전송 옵션 설정
#Set-DnsServerPrimaryZone -Name $ sec.ZoneName -SecureSecondaries TransferToSecureServers
# NoTransfer : 영역 전송 사용 X
# TransferAnyServer : 영역 전송 사용 O, 아무 서버로
# TransferToZoneNameServer : 영역 전송 사용 O, 이름 서버 탭에 나열된 서버로만
# TransferToSecureServers : 영역 전송 사용 O, 다음 서버로만 (특정 서버를 지정하여 설정)


###############################################

########### 58. 터미널 서비스 암호화 수준 설정 ###########

$index = "58"
$title = "터미널 서비스 암호화 수준 설정"
$importance = "중"
$RV = "터미널 서비스 사용X / 암호화 수준 '클라이언트와 호환 가능(중간)' 이상으로 설정"

# 레지스트리 키 경로 및 값 설정
$key = "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp"
$valueName = "MinEncryptionLevel"
$newValue = 2

# 레지스트리 값을 설정
Set-ItemProperty -Path $key -Name $valueName -Value $newValue

$CV = "MinEncryptionLevel 2로 설정"
Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV
# Write-Host ($index + "#" + $root_title + + "#" + $title + "#" + "MinEncryptionLevel 2로 설정") >> action_result.txt

###############################################

########### 59. IIS 웹 서비스 정보 숨김 ###########

$index = "59"
$title = "IIS 웹 서비스 정보 숨김"

$RV = "웹 서비스의 에러 페이지를 별도로 지정한다."
$importance = "중"

for ($X = 0; $X -lt $Site_Name_list.count; $X++) {
  $Web_Property_Filter = "/system.webserver/httpErrors"
  $Error_Mode = Get-WebConfigurationProperty -Filter $Web_Property_Filter -name errormode -PSPath $Site_Path_list[$X]
  # 오류 모드를 사용자 정의 오류 페이지로 설정
  if ($Error_Mode -ne "Custom") {
    Set-WebConfigurationProperty -Filter $Web_Property_Filter -PSPath $Site_Path_list[$X] -Name "errorMode" -Value "Custom"
    Write-Host "[$($Site_Name_list[$X])] 사용자 정의 오류 페이지로 변경됨."
  }
}

$CV = "사용자 정의 오류 페이지로 정의"
Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV
# Write-Host ($index + "#" + $root_title + + "#" + $title + "#" + "사용자 정의 오류 페이지로 정의") >> action_result.txt

###############################################

########### 60. SNMP 서비스 구동 점검 ###########

$index = "60"
$title = "SNMP 서비스 구동 점검"

$RV = "SNMP 서비스 사용하지 않는 경우"
$importance = "중"

# SNMP 서비스 이름 설정
$snmpService = "SNMP"

# SNMP 서비스 상태 확인
$service = Get-Service -Name $snmpService

# SNMP 서비스 중지
Write-Host "SNMP 서비스가 실행 중입니다. 중지 중..."
Stop-Service -Name $snmpService -Force
Write-Host "SNMP 서비스가 중지되었습니다."

# SNMP 서비스 시작 유형을 '사용 안 함'으로 설정
Set-Service -Name $snmpService -StartupType Disabled
Write-Host "SNMP 서비스가 사용 안 함으로 설정되었습니다."

$CV = "SNMP 서비스가 사용 안 함 설정"
Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV
# Write-Host ($index + "#" + $root_title + + "#" + $title + "#" + "SNMP 서비스가 사용 안 함 설정") >> action_result.txt

###############################################

########### 61. SNMP 서비스 커뮤니티 스트링의 복잡성 설정 ###########

$index = "61"
$title = "SNMP 서비스 커뮤니티 스트링의 복잡성 설정"

$RV = "SNMP 서비스 사용X / Community String 이 public 혹은 private 가 아님"
$importance = "중"

# 레지스트리에서 SNMP Community Strings 확인
$Community_Strings = Get-RegistryValue "HKLM\SYSTEM\CurrentControlSet\services\SNMP\Parameters\ValidCommunities"

# public 또는 private 문자열이 있으면 제거
foreach ($item in $Community_Strings) {
  if ($item.Name -like "*public*" -or $item.Name -like "*private*") {
    Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\services\SNMP\Parameters\ValidCommunities" -Name $item.Name
  }
}

$CV = "public, private 제거"
Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV
# Write-Host ($index + "#" + $root_title + + "#" + $title + "#" + "public, private 제거") >> action_result.txt

###############################################

########### 62. SNMP Access control 설정 ###########

$index = "62"
$title = "SNMP Access control 설정"

$RV = "특정 호스트에게만 SNMP 패킷 받아들이기로 설정"
$importance = "중"

$regPath = "HKLM:\SYSTEM\CurrentControlSet\services\SNMP\Parameters\PermittedManagers"
$allowedHost = "localhost"
Set-ItemProperty -Path $regPath -Name "1" -Value $allowedHost

$CV = "특정 호스트에게만 패킷 받기 설정"
Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV
# Write-Host ($index + "#" + $root_title + + "#" + $title + "#" + "특정 호스트에게만 패킷 받기 설정") >> action_result.txt

###############################################

########### 63. DNS 서비스 구동 점검 ###########

$index = "63"
$title = "DNS 서비스 구동 점검"

$RV = "DNS 서비스를 사용하지 않거나 동적 업데이트를 사용하지 않음"
$importance = "중"

# Get all DNS zones on the DNS server
$dnsZones = Get-DnsServerZone

foreach ($zone in $dnsZones) {
  # Disable dynamic updates for the DNS zone
  Set-DnsServerZone -Name $zone.ZoneName -DynamicUpdate None
    
  Write-Host "Dynamic updates disabled for zone: $($zone.ZoneName)"
}

# Verify the configuration
foreach ($zone in $dnsZones) {
  $zoneConfig = Get-DnsServerZone -Name $zone.ZoneName
  Write-Host "Zone: $($zone.ZoneName), Dynamic Update Setting: $($zoneConfig.DynamicUpdate)"
}

$CV = "DNS 동적 업데이트 비활성화"
Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV
# Write-Host ($index + "#" + $root_title + + "#" + $title + "#" + "DNS 동적 업데이트 비활성화") >> action_result.txt

###############################################

########### 64. HTTP/FTP/SNMP 배너 차단 ###########

$index = "64"
$title = "HTTP/FTP/SMTP 배너 차단"

$RV = "배너 정보가 보이지 않는 경우"
$importance = "하"

# 레지스트리 경로 설정
$RegPath = "HKLM\SYSTEM\CurrentControlSet\Services\HTTP"
$ValueName = "DisableServerHeader"

# 레지스트리 값 가져오기
$existingValue = Get-ItemProperty -Path $RegPath -Name $ValueName -ErrorAction SilentlyContinue

if ($existingValue) {
  # 값이 존재하면 1로 설정
  if ($existingValue.$ValueName -ne 1) {
    Set-ItemProperty -Path $RegPath -Name $ValueName -Value 1
  }
}
else {
  # 값이 없으면 새로 추가
  New-ItemProperty -Path $RegPath -Name $ValueName -Value 1 -PropertyType DWord
}


$total_web_count = 0
$tempSTR = @()

#FTP banner setting Read

# FTP 서비스가 설치되어 있는지 확인
if (-not (Get-WindowsFeature -Name Web-Ftp-Server).Installed) {
  Write-Host "FTP 서비스가 설치되어 있지 않습니다."
  exit
}

# 각 FTP 사이트에 대해 배너 정보 숨기기 설정
foreach ($site in $FTP_Site_List) {
  $ftpSitePath = "IIS:\Sites\$($site.Name)"

  # FTP 배너 비활성화
  Set-WebConfigurationProperty -Filter "/system.ftpServer/security/ftpRequestLogging" -PSPath $ftpSitePath -Name "logInactivity" -Value $false
  Set-WebConfigurationProperty -Filter "/system.ftpServer/security/ftpRequestLogging" -PSPath $ftpSitePath -Name "logPath" -Value "$null"
}

$CV = "모든 사이트의 배너 정보가 숨김"
Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV
# Write-Host ($index + "#" + $root_title + + "#" + $title + "#" + "모든 사이트의 배너 정보가 숨김") >> action_result.txt

###############################################

########### 65. Telnet 보안 설정 ###########

$index = "65"
$title = "Telnet 보안 설정"

$RV = "Telnet 서비스를 사용하지 않을 때"
$importance = "중"

if ((Get-Service -Name "*telnet*").count -gt 0) {
  $result = "취약"
  $CV = "telnet 서비스를 사용하고 있습니다."
}
else {
  $result = "양호"
  $CV = "telnet 서비스를 사용하지 않습니다."
}

# Telnet 서비스 확인
$telnetService = Get-Service -Name "*telnet*"

# Telnet 서비스 중지
if ($telnetService.Status -eq "Running") {
  Stop-Service -Name "*telnet*" -Force
}

# Telnet 서비스 비활성화
Set-Service -Name "*telnet*" -StartupType Disabled

$CV = "Telnet 서비스 비활성화"
Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV
# Write-Host ($index + "#" + $root_title + + "#" + $title + "#" + "Telnet 서비스 비활성화") >> action_result.txt

###############################################

########### 66. 불필요한 ODBC / OLE-DB 데이터 소스와 드라이브 제거 ###########

$index = "66"
$title = "불필요한 ODBC / OLE-DB 데이터 소스와 드라이브 제거"

$RV = "시스템 DSN 부분의 Data Source를 현재 사용하는 경우"
$importance = "중"

# ODBC 데이터 원본 목록 가져오기
$odbc_list = Get-OdbcDsn

# ODBC 데이터 원본이 존재하는지 확인
if ($odbc_list) {
  # ODBC 데이터 원본이 존재할 경우, 각 데이터 원본 제거
  foreach ($odbc in $odbc_list) {
    # ODBC 데이터 원본 제거
    Remove-OdbcDsn -Name $odbc.Name -DsnType $odbc.DsnType
  }
}

$CV = "ODBC 데이터 원본 삭제"
Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV
# Write-Host ($index + "#" + $root_title + + "#" + $title + "#" + "ODBC 데이터 원본 삭제") >> action_result.txt

###############################################

########### 67. 원격 터미널 접속 타임아웃 설정 ###########

$index = "67"
$title = "원격 터미널 접속 타임아웃 설정"

$RV = "원격제어 시 Timeout 제어 설정을 적용한 경우"
$importance = "중"

# 레지스트리 경로 및 키 설정
$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
$regKeyIdleTime = "MaxIdleTime"
$idleTimeValue = 1800000  # 30분을 초로 설정

# 레지스트리 경로가 존재하는지 확인
if (-not (Test-Path $regPath)) {
    # 레지스트리 경로가 없으면 생성
    New-Item -Path $regPath -Force
}

# MaxIdleTime 값을 30분으로 설정
Set-ItemProperty -Path $regPath -Name $regKeyIdleTime -Value $idleTimeValue

# 결과 출력
$currentValue = Get-ItemProperty -Path $regPath -Name $regKeyIdleTime

$CV = "MaxIdleTime 30분으로 설정"
Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV
# Write-Host ($index + "#" + $root_title + + "#" + $title + "#" + "MaxIdleTime 30분으로 설정") >> action_result.txt

###############################################

#############################################################################################################################