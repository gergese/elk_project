###############################################

########### 41. 보안 감사를 로그할 수 없는 경우 즉시 시스템 종료 해제 ###########

$index = $checklist.check_list[40].code
$title = $checklist.check_list[40].title
$root_title = $checklist.check_list[40].root_title

$RV = "해당 정책을 사용 하지 않을 경우"
$importance = $checklist.check_list[40].importance

$flag = (Get-RegistryValue "HKLM\SYSTEM\CurrentControlSet\Control\Lsa\" | Where-Object { $_.Name -like "*crashonauditfail*" }).Value

if ($flag -eq 0) {
    $result = "양호"
    $CV = "'보안 감사를 로그할 수 없는 경우 즉시 시스템 종료 옵션' 을 사용하지 않습니다."
}
else {
    $result = "취약"
    $CV = "'보안 감사를 로그할 수 없는 경우 즉시 시스템 종료 옵션' 을 사용하는 중입니다."
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title