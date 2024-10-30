###############################################

###### 5. 해독 가능한 암호화를 사용하여 암호 저장 해제 ######

$index = $checklist.check_list[4].code
$title = $checklist.check_list[4].title
$root_title = $checklist.check_list[4].root_title
$importance = $checklist.check_list[4].importance

$tempStr = Get-Content user_rights.inf | Select-String "PasswordComplexity"
$tempStr = Out-String -InputObject $tempStr
$tempStr = $tempStr.Split('=')
$count = $tempStr[-1].Trim()


if($count)
{
    $result = "취약"
    $CV = "해당 옵션 사용 중"
}
else
{
    $result = "양호"
    $CV = "해당 옵션 사용 안 함"
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title