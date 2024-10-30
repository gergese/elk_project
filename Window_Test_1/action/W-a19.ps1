###############################################

########### 19. IIS 가상 디렉토리 삭제 ###########

$index = $checklist.check_list[18].code
$title = $checklist.check_list[18].title
$root_title = $checklist.check_list[18].root_title
$importance = $checklist.check_list[18].importance



Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title