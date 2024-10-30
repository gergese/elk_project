###############################################

########### 80. 컴퓨터 계정 암호 최대 사용 기간 ###########

$index = $checklist.check_list[79].code
$title = $checklist.check_list[79].title
$root_title = $checklist.check_list[79].root_title

$RV = "'컴퓨터 계정 암호 변경 사용 안 함' 정책을 사용하지 않으며, '컴퓨터 계정 암호 최대 사용기간'이 90일로 설정"
$importance = $checklist.check_list[79].importance

$CV = @()

$flag_1 = (Get-RegistryValue "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" | Where-Object { $_.Name -eq "DisablePasswordChange" }).Value
$flag_2 = (Get-RegistryValue "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" | Where-Object { $_.Name -eq "MaximumPasswordAge" }).Value

if ($flag_1 -eq 0) {
    $result = "양호"
    $CV += "'컴퓨터 계정 암호 변경 사용 안 함' 정책을 사용하지 않으며, "
}
else {
    $result = "취약"
    $CV += "'컴퓨터 계정 암호 변경 사용 안 함' 정책을 사용하며, "
}

if ($flag_2 -le 90) {
    $CV += "컴퓨터 계정 암호 최대 사용 기간이 " + $flag_2.toString() + "일로 설정"
}
else {
    $result = "취약"
    $CV += "컴퓨터 계정 암호 최대 사용 기간이 " + $flag_2.toString() + "일로 설정"
}


Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title