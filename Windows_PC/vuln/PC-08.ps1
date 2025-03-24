###############################################

########### 8. MS-Office, 한글, 어도비 아크로뱃 등의 응용 프로그램에 대한 최신 보안패치 및 벤더 권고사항 적용 ###########

$index = $checklist.check_list[7].code
$title = $checklist.check_list[7].title
$root_title = $checklist.check_list[7].root_title
$result = "수동"
$importance = $checklist.check_list[7].importance
$CV = "수동 점검"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title