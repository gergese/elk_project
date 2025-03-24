###############################################

########### 14. PC 내부의 미사용(3개월) ActiveX 제거 ###########

$index = $checklist.check_list[13].code
$title = $checklist.check_list[13].title
$root_title = $checklist.check_list[13].root_title
$importance = $checklist.check_list[13].importance
$result = "수동"
$CV = "수동 점검"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title