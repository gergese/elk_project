﻿###############################################

########### 69. 로그의 정기적 검토 및 보고 ###########

$index = $checklist.check_list[68].code
$title = $checklist.check_list[68].title
$root_title = $checklist.check_list[68].root_title
$result = "수동"

$importance = $checklist.check_list[68].importance

$CV = "수동 점검"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title