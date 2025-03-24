###############################################

########### 7. 최신 서비스팩 적용 ###########

$index = $checklist.check_list[6].code
$title = $checklist.check_list[6].title
$root_title = $checklist.check_list[6].root_title
$result = "수동"
$importance = $checklist.check_list[6].importance
$CV = "수동 점검"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title