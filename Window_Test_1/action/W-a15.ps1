###############################################

########### 15. 웹 프로세스 권한 제한 ###########

$index = $checklist.check_list[14].code
$title = $checklist.check_list[14].title
$root_title = $checklist.check_list[14].root_title
$result = "수동"
$importance = $checklist.check_list[14].importance



Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title