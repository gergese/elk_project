###############################################

########### 43. Autologin 기능 제어 ###########

$index = $checklist.check_list[42].code
$title = $checklist.check_list[42].title
$root_title = $checklist.check_list[42].root_title

$RV = "AutoAdminLogon 값이 없거나 0으로 설정되어 있는 경우"
$importance = $checklist.check_list[42].importance

$flag = Test-RegistryValue "HKLM\SOFTWARE\Microsoft\WindowsNT\CurrentVersion\Winlogon" "AutoAdminLogon"

if ($flag) {
    $flag = (Get-RegistryValue "HKLM\SOFTWARE\Microsoft\WindowsNT\CurrentVersion\Winlogin" | Where-Object { $_.Name -eq "AutoAdminLogon" }).Value
    
    if ($flag -eq 1) {
        $result = "취약"
        $CV = "AutoAdminLogon 기능을 사용하는 중입니다."
    }
    else {
        $result = "양호"
        $CV = "AutoAdminLogon 기능을 사용하지 않습니다."
    }
}
else {
    $result = "양호"
    $CV = "AutoAdminLogon 기능을 사용하지 않습니다."
} 

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title