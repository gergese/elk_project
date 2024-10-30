###############################################

########### 22. IIS Exec 명령어 쉘 호출 진단 ###########

$index = $checklist.check_list[21].code
$title = $checklist.check_list[21].title
$root_title = $checklist.check_list[21].root_title
$importance = $checklist.check_list[21].importance



Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title