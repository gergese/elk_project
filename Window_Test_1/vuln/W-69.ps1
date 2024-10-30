###############################################

########### 69. 로그의 정기적 검토 및 보고 ###########

$index = $checklist.check_list[68].code
$title = $checklist.check_list[68].title
$root_title = $checklist.check_list[68].root_title
$result = "수동"

$RV = "접속기록 등의 보안 로그, 응용 프로그램 및 시스템 로그 기록에 대해 정기적으로 검토, 분석, 리포트 작성 및 보고 등의 조치가 이루어지는 경우"
$importance = $checklist.check_list[68].importance

$CV = "수동 점검"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title