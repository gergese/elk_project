###############################################

########### 29. DNS Zone Transfer 설정 ###########


$index = $checklist.check_list[28].code
$title = $checklist.check_list[28].title
$root_title = $checklist.check_list[28].root_title
$importance = $checklist.check_list[28].importance

$CV = "DNS 사용 여부에 맞게 수정해 주세요"
$result = "수동"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title