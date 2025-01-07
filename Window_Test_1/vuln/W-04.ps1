###############################################

########### 4. 계정 잠금 임계값 설정 ###########

$index = $checklist.check_list[3].code
$title = $checklist.check_list[3].title
$root_title = $checklist.check_list[3].root_title
$importance = $checklist.check_list[3].importance

$tempStr = Get-Content user_rights.inf | Select-String "LockoutBadCount"
$tempStr = Out-String -InputObject $tempStr
$tempStr = $tempStr.Split('=')
$count = [int]($tempStr[-1].Trim())


if($count)
{
    if($count -eq 0)
    {
        $result = "취약"
        $CV = $count
        $CV = $CV
        $CV = "계정 잠금 임계값 미 설정"
    }
    elseif($count -le 5)
    {
        $result = "양호"
        $CV = $count
        $CV = $CV
        $CV = "현재 계정 잠금 임계값은 " + $CV + "회"
    }
    elseif($count -ge 6)
    {
        $result = "취약"
        $CV = $count
        $CV = $CV
        $CV = "현재 계정 잠금 임계값은 " + $CV + "회"
    }
}
else
{
    $result = "취약"
    $CV = "계정 잠금 임계값 미 설정"
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title
