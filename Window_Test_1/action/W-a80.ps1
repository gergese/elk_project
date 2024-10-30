###############################################

########### 80. 컴퓨터 계정 암호 최대 사용 기간 ###########

$index = $checklist.check_list[79].code
$title = $checklist.check_list[79].title
$root_title = $checklist.check_list[79].root_title

$importance = $checklist.check_list[79].importance

$CV = @()

# 레지스트리 값 확인
$flag_1 = (Get-RegistryValue "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" | Where-Object { $_.Name -eq "DisablePasswordChange" }).Value
$flag_2 = (Get-RegistryValue "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" | Where-Object { $_.Name -eq "MaximumPasswordAge" }).Value

# 취약한 부분을 양호하게 수정
# DisablePasswordChange 값이 0이 아닌 경우, 0으로 설정 (정책 사용 안 함)
if ($flag_1 -ne 0) {
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" -Name "DisablePasswordChange" -Value 0
    $CV += "'컴퓨터 계정 암호 변경 사용 안 함' 정책을 비활성화했으며, "
} else {
    $CV += "'컴퓨터 계정 암호 변경 사용 안 함' 정책이 이미 비활성화되어 있으며, "
}

# MaximumPasswordAge 값이 90일 초과인 경우, 90으로 설정 (암호 최대 사용 기간 90일로 설정)
if ($flag_2 -gt 90) {
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" -Name "MaximumPasswordAge" -Value 90
    $CV += "컴퓨터 계정 암호 최대 사용 기간을 90일로 설정했습니다."
} else {
    $CV += "컴퓨터 계정 암호 최대 사용 기간이 이미 " + $flag_2.toString() + "일로 설정되어 있습니다."
}

# 결과를 양호로 설정
$result = "양호"

# 결과 데이터를 저장
Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title