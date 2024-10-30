###############################################

########### 60. SNMP 서비스 구동 점검 ###########

$index = $checklist.check_list[59].code
$title = $checklist.check_list[59].title
$root_title = $checklist.check_list[59].root_title

$RV = "SNMP 서비스 사용하지 않는 경우"
$importance = $checklist.check_list[59].importance

$flag = (Get-Service -Name *SNMP* | Where-Object {$_.Status -like "*Running*"}).count

if($flag -gt 0)
{
    $result = "취약"
    $CV = "SNMP가 현재 실행 중"
}
else
{
    $result = "양호"
    $CV = "SNMP가 현재 동작하지 않는다."
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title