###############################################

########### 75. 경고 메세지 설정 ###########

$index = $checklist.check_list[74].code
$title = $checklist.check_list[74].title
$root_title = $checklist.check_list[74].root_title

$RV = "로그인 경고 메세지 제목 및 내용이 설정되어 있는 경우"
$importance = $checklist.check_list[74].importance

$tempSTR = @(0, 0)

$flag_title = (Get-RegistryValue "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" | Where-Object { $_.Name -eq "legalnoticecaption" }).Value
$flag_text = (Get-RegistryValue "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" | Where-Object { $_.Name -eq "legalnoticetext" }).Value

if ($flag_title.length -eq 0) {
    $result = "취약"
    $tempSTR[0] = "로그인 경고 제목이 설정되어 있지 않습니다."
}
else {
    if ($flag_text.length -eq 0 -or $flag_text -eq '') {
        $result = "취약"
        $tempSTR[1] = "로그인 경고 내용이 설정되어 있지 않습니다."
    }
    else {
        $result = "양호"
        $tempSTR[0] = "설정된 로그인 경고 제목은 '" + $flag_title + "' 입니다."
        $tempSTR[1] = "설정된 로그인 경고 내용은 '" + $flag_text + "' 입니다."
    }
}


$CV = $tempSTR[0] + $tempSTR[1]

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title