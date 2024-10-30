###############################################

########### 10 .IIS 서비스 구동 점검 ##########

$index = $checklist.check_list[9].code
$title = $checklist.check_list[9].title
$root_title = $checklist.check_list[9].root_title
$result = "수동"
$importance = $checklist.check_list[9].importance



Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title