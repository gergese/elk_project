###############################################

########### 10. 바이러스 백신 프로그램에서 제공하는 실시간 감시 기능 활성화 ###########

$index = $checklist.check_list[9].code
$title = $checklist.check_list[9].title
$root_title = $checklist.check_list[9].root_title
$result = "수동"
$importance = $checklist.check_list[9].importance
$CV = "수동 점검"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title