﻿###############################################

########### 45. 디스크 볼륨 암호화 설정 ###########

$index = $checklist.check_list[44].code
$title = $checklist.check_list[44].title
$root_title = $checklist.check_list[44].root_title
$result = "수동"

$RV = "'데이터 보호를 위해 내용을 암호화' 정책을 선택"
$importance = $checklist.check_list[44].importance

$CV = "수동 점검"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title