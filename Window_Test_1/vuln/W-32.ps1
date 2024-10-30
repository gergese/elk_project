###############################################

########### 32. 최신 HOT FIX 적용 ###########

$index = $checklist.check_list[31].code
$title = $checklist.check_list[31].title
$root_title = $checklist.check_list[31].root_title
$result = "수동"

$RV = "최신 Hotfix가 있는지 주기적으로 모니터링하고 반영하거나, PMS (Patch Management System) Agent가 설치되어 자동패치배포가 적용된 경우"
$importance = $checklist.check_list[31].importance

$CV = "수동 점검"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title