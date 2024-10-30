###############################################

######### 51. 패스워드 최소 사용 기간 #########

$index = $checklist.check_list[50].code
$title = $checklist.check_list[50].title
$root_title = $checklist.check_list[50].root_title
$RV = "0보다 큰 값"
$importance = $checklist.check_list[50].importance

$tempStr = Get-Content user_rights.inf | Select-String "MinimumPasswordAge"
$tempStr = Out-String -InputObject $tempStr
$tempStr = $tempStr.Split('=')
$count = $tempStr[-1].Trim()


if($count)
{
    if($count -gt 0)
    {
        $result = "양호"
        $CV = $count
        $CV = $CV
        $CV += "일"
    }
    else
    {
        $result = "취약"
        $CV = $count
        $CV = $CV
        $CV += "일"
    }
}
else
{
    $result = "취약"
    $CV = "설정X"
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title