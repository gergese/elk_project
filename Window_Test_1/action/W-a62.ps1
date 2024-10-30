###############################################

########### 62. SNMP Access control 설정 ###########

$index = $checklist.check_list[61].code
$title = $checklist.check_list[61].title
$root_title = $checklist.check_list[61].root_title
$importance = $checklist.check_list[61].importance

$regPath = "HKLM:\SYSTEM\CurrentControlSet\services\SNMP\Parameters\PermittedManagers"
$allowedHost = "localhost"
Set-ItemProperty -Path $regPath -Name "1" -Value $allowedHost

$CV = "특정 호스트에게만 패킷 받기 설정"
$result = "양호"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title