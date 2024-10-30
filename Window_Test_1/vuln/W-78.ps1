###############################################

########### 78. 보안 채널 데이터 디지털 암호화 또는 서명 ###########

$index = $checklist.check_list[77].code
$title = $checklist.check_list[77].title
$root_title = $checklist.check_list[77].root_title

$RV = "도메인 구성원 정책 중 '보안 채널 데이터를 디지털 암호화 또는, 서명' / '보안 채널 데이터 디지털 암호화(가능한 경우)' / '보안 채널 데이터 서명(가능한 경우)' 정책이 '사용' 상태인 경우"
$importance = $checklist.check_list[77].importance

$tempSTR = @()

$flag_1 = (Get-RegistryValue "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" | Where-Object { $_.Name -eq "RequireSignOrSeal" }).Value
$flag_2 = (Get-RegistryValue "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" | Where-Object { $_.Name -eq "SealSecureChannel" }).Value
$flag_3 = (Get-RegistryValue "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" | Where-Object { $_.Name -eq "SignSecureChannel" }).Value

if ($flag_1 -eq 1 -and $flag_2 -eq 1 -and $flag_3 -eq 1) {
    $result = "양호"
    $CV = "3가지 정책 모두 사용 중"
}
else {
    if ($flag_1 -eq 0) {
        $result = "취약"
        $tempSTR += "'보안 채널 데이터를 디지털 암호화 또는, 서명' 정책"
        $tempSTR += ','
    }
    if ($flag_1 -eq 0) {
        $result = "취약"
        $tempSTR += "'보안 채널 데이터 디지털 암호화' 정책"
        $tempSTR += ','
    }
    if ($flag_1 -eq 0) {
        $result = "취약"
        $tempSTR += "'보안 채널 데이터 서명' 정책"
        $tempSTR += ','
    }

    if ($tempSTR.count -gt 0) {
        $tempSTR[-1] = ''
    }

    $CV = $tempSTR + "을 사용하고 있지 않습니다."
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title