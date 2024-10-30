###############################################

########### 33. 백신 프로그램 업데이트 ###########

$index = $checklist.check_list[32].code
$title = $checklist.check_list[32].title
$root_title = $checklist.check_list[32].root_title
$result = "수동"

$RV = "바이러스 백신 프로그램의 최신 엔진 업데이트가 설치되어 있거나, 망 격리 환경의 경우 백신 업데이트를 위한 절차 및 적용 방법이 수립된 경우"
$importance = $checklist.check_list[32].importance

$CV = "수동 점검"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title