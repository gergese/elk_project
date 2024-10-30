###############################################

########### 62. SNMP Access control 설정 ###########

$index = $checklist.check_list[61].code
$title = $checklist.check_list[61].title
$root_title = $checklist.check_list[61].root_title

$RV = "특정 호스트에게만 SNMP 패킷 받아들이기로 설정"
$importance = $checklist.check_list[61].importance

$flag = (Get-Service -Name *SNMP* | Where-Object { $_.Status -like "*Running*" }).count
if ($flag -gt 0) {

  $setting = Get-RegistryValue "HKLM\SYSTEM\CurrentControlSet\services\SNMP\Parameters\PermittedManagers"
  $setting_count = ($setting.Value).count

  if ($setting_count -gt 1) {
    $result = "양호"
    $CV = "특정 사용자에게 SNMP 패킷 받아들이기가 가능하도록 설정되어 있습니다."
  }
  else {
    $result = "취약"
    $CV = "모든 사용자에게 SNMP 패킷 받아들이기가 가능하도록 설정되어 있습니다."
  }
}
else {
  $result = "양호"
  $CV = "SNMP가 구동되지 않은 상태입니다."
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title