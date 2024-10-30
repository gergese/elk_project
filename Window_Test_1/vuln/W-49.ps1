###############################################

######## 49. 패스워드 최소 암호 길이 ##########

$index = $checklist.check_list[48].code
$title = $checklist.check_list[48].title
$root_title = $checklist.check_list[48].root_title
$RV = "8(자)이상"
$importance = $checklist.check_list[48].importance

$tempStr = Get-Content user_rights.inf | Select-String "MinimumPasswordLength"
$tempStr = Out-String -InputObject $tempStr
$tempStr = $tempStr.Split('=')
$count = $tempStr[-1].Trim()


if($count)
{
    if($count -ge 8)
    {
        $result = "양호"
        $CV = $count
        $CV = $CV
        $CV += "자"
    }
    else
    {
        $result = "취약"
        $CV = $count
        $CV = $CV
        $CV += "자"
    }
}
else
{
    $result = "취약"
    $CV = "해당 옵션이 설정되어 있지 않습니다."
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title