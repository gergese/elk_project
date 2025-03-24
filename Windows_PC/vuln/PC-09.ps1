###############################################

########### 9. 바이러스 백신 프로그램 설치 및 주기적 업데이트 ###########

$index = $checklist.check_list[8].code
$title = $checklist.check_list[8].title
$root_title = $checklist.check_list[8].root_title
$result = "수동"
$importance = $checklist.check_list[8].importance
$CV = "수동 점검"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title