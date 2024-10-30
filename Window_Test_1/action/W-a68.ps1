###############################################

########### 68. 예약된 작업에 의심스러운 명령이 등록되어 있는지 점검 ###########

$index = $checklist.check_list[67].code
$title = $checklist.check_list[67].title
$root_title = $checklist.check_list[67].root_title
$result = "수동"

$CV = "예약된 작업 목록 중 불필요한 작업은 삭제하여 주세요."
$importance = $checklist.check_list[67].importance

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title