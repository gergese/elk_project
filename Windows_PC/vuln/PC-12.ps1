###############################################

########### 12. 화면보호기 대기 시간 설정 및 재시작 시 암호 보호 설정 ###########

$index = $checklist.check_list[11].code
$title = $checklist.check_list[11].title
$root_title = $checklist.check_list[11].root_title
$importance = $checklist.check_list[11].importance

$Timeout = (Get-RegistryValue "HKCU\Control Panel\Desktop\" | Where-Object { $_.Name -like "*ScreenSaveTimeOut*" }).Value
$Secure = (Get-RegistryValue "HKCU\Control Panel\Desktop\" | Where-Object { $_.Name -like "*ScreenSaveActive*" }).Value
$Lock = (Get-RegistryValue "HKCU\Control Panel\Desktop\" | Where-Object { $_.Name -like "*ScreenSaverIsSecure*" }).Value

if (($Timeout / 60) -le 10 -and $Secure -eq 1 -and $Lock -eq 1) {
    $result = "양호"
    $CV = "화면 보호기 설정 O / 해제시 비밀번호 요청 O / 현재 대기 시간" + ($Timeout / 60).toString() + "분 입니다."
}
elseif ($Timeout -eq $null -and $Secure -eq $null) {
    $result = "취약"
    $CV = "화면 보호기가 기본 옵션으로 설정되어 있습니다."
}
else {
    if (($Timeout / 60) -gt 10) {
        $result = "취약"
        $CV = "화면 보호기 설정O / 현재 대기 시간" + ($Timeout / 60).toString() + "분 입니다."
    }
    if ($Secure -eq 0) {
        $result = "취약"
        $CV = "화면 보호기 설정O / 해제시 비밀번호 요청 X"
    }
    else {
        $result = "취약"
        $CV = "화면 보호기 설정x / 해제시 비밀번호 요청 X"
    }
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title