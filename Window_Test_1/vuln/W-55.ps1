###############################################

############## 55. 최근 암호 기억 ##############

$index = $checklist.check_list[54].code
$title = $checklist.check_list[54].title
$root_title = $checklist.check_list[54].root_title
$RV = "4(개)이상"
$importance = $checklist.check_list[54].importance

$tempStr = Get-Content user_rights.inf | Select-String "PasswordHistorySize"
$tempStr = Out-String -InputObject $tempStr
$tempStr = $tempStr.Split('=')
$count = $tempStr[-1].Trim()

if($count)
{
    if($count -ge 4)
    {
        $result = "양호"
        $CV = $count
        $CV = $CV
        $CV += "개"
    }
    else
    {
        $result = "취약"
        $CV = $count
        $CV = $CV
        $CV += "개"
    }
}
else
{
    $result = "취약"
    $CV = "해당 옵션이 설정되어 있지 않습니다."
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title