###############################################

########### 61. SNMP 서비스 커뮤니티 스트링의 복잡성 설정 ###########

$index = $checklist.check_list[60].code
$title = $checklist.check_list[60].title
$root_title = $checklist.check_list[60].root_title
$importance = $checklist.check_list[60].importance

# 레지스트리에서 SNMP Community Strings 확인
$Community_Strings = Get-RegistryValue "HKLM\SYSTEM\CurrentControlSet\services\SNMP\Parameters\ValidCommunities"

# public 또는 private 문자열이 있으면 제거
foreach ($item in $Community_Strings) {
    if ($item.Name -like "*public*" -or $item.Name -like "*private*") {
        Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\services\SNMP\Parameters\ValidCommunities" -Name $item.Name
    }
}

$CV = "public, private 제거"
$result = "양호"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title