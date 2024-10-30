###############################################

########### 32. 최신 HOT FIX 적용 ###########

$index = $checklist.check_list[31].code
$title = $checklist.check_list[31].title
$root_title = $checklist.check_list[31].root_title
$result = "수동"

$importance = $checklist.check_list[31].importance

$CV = "수동 점검"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title