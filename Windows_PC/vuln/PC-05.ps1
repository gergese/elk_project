###############################################

######## 5. Windows Messenger(MSN, .NET 메신저 등)와 같은 상용 메신저의 사용 금지 ##########

$index = $checklist.check_list[4].code
$title = $checklist.check_list[4].title
$root_title = $checklist.check_list[4].root_title
$importance = $checklist.check_list[4].importance
$result = "수동"
$CV = "사용중인 상용 메신저 확인 필요"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title