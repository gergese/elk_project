###############################################

######### 11. OS에서 제공하는 침입차단 기능 활성화 #########

$index = $checklist.check_list[10].code
$title = $checklist.check_list[10].title
$root_title = $checklist.check_list[10].root_title
$importance = $checklist.check_list[10].importance

$status = Get-NetFirewallProfile | Format-Table Name, Enabled
if($status -eq "True") {
    $CV = "양호"
    $result = "Windows 방화벽 사용 중"
}
else {
    $CV = "수동"
    $result = "방화벽 사용 여부 확인 필요"
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title