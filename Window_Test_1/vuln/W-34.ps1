﻿########### 34. 로그의 정기적 검토 및 보고 ###########

$index = $checklist.check_list[33].code
$title = $checklist.check_list[33].title
$root_title = $checklist.check_list[33].root_title
$result = "수동"

$RV = "로그 , 응용 프로그램 및 시스템 로그 기록에 대해 정기적으로 검토 분석등이 이루어지는 경우"
$importance = $checklist.check_list[33].importance
$CV = "수동 확인"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title