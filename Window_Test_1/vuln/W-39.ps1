###############################################

########### 39. 로그온 하지 않고 시스템 종료 허용 해제 ###########

$index = $checklist.check_list[38].code
$title = $checklist.check_list[38].title
$root_title = $checklist.check_list[38].root_title

$RV = "'사용 안함' 옵션으로 설정"
$importance = $checklist.check_list[38].importance

$flag = (Get-RegistryValue "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" | Where-Object { $_.Name -eq "shutdownwithoutlogon" }).Value

if ($flag -eq 0) {
    $result = "양호"
    $CV = "로그온 하지 않고 시스템 종료가 허용되지 않습니다."
}
else {
    $result = "취약"
    $CV = "로그온 하지 않고 시스템 종료가 허용됩니다."   
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title