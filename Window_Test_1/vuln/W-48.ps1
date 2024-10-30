###############################################

########### 48. 패스워드 복잡성 설정 ##########

$index = $checklist.check_list[47].code
$title = $checklist.check_list[47].title
$root_title = $checklist.check_list[47].root_title
$RV = "사용"
$importance = $checklist.check_list[47].importance

$tempStr = Get-Content user_rights.inf | Select-String "PasswordComplexity"
$tempStr = Out-String -InputObject $tempStr
$tempStr = $tempStr.Split('=')
$count = $tempStr[-1].Trim()


if($count)
{
    $result = "양호"
    $CV = "해당 옵션 사용 중"
}
else
{
    $result = "취약"
    $CV = "해당 옵션 사용 안 함"
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title