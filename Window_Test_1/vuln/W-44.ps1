###############################################

########### 44.이동식 미디어 포맷 및 꺼내기 허용 ###########

$index = $checklist.check_list[43].code
$title = $checklist.check_list[43].title
$root_title = $checklist.check_list[43].root_title

$RV = "해당 옵션 정책이 'Administrator' 로 설정되어 있는 경우"
$importance = $checklist.check_list[43].importance

$flag = Test-RegistryValue "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" "AllocateDASD"

if ($flag) {
    $flag = (Get-RegistryValue "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" | Where-Object { $_.Name -eq "AllocateDASD" }).Value
    
    if ($flag -eq 0) {
        $result = "양호"
        $CV = "Administrator"
    }
    elseif ($flag -eq 1) {
        $result = "취약"
        $CV = "Administrator 및 Power Users"
    }
    elseif ($flag -eq 2) {
        $result = "취약"
        $CV = "Administrator 및 Interactive Users"
    }
}
else {
    $result = "취약"
    $CV = "'이동식 미디어 포맷 및 꺼내기 허용' 옵션의 설정값을 지정하지 않았습니다."
} 

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title