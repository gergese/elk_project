###############################################

########### 60. SNMP 서비스 구동 점검 ###########

$index = $checklist.check_list[59].code
$title = $checklist.check_list[59].title
$root_title = $checklist.check_list[59].root_title
$importance = $checklist.check_list[59].importance

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
$result = "양호"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title