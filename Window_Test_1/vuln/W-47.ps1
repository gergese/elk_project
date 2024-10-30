###############################################

########### 47. 계정 잠금 기간 설정 ###########

$index = $checklist.check_list[46].code
$title = $checklist.check_list[46].title
$root_title = $checklist.check_list[46].root_title
$RV = "60(분)이상"
$importance = $checklist.check_list[46].importance

$tempStr = Get-Content user_rights.inf | Select-String "LockoutDuration"
$tempStr = Out-String -InputObject $tempStr
$tempStr = $tempStr.Split('=')
$count = $tempStr[-1].Trim()


if($count)
{
    if($count -ge 60)
    {
        $result = "양호"
        $CV = $count.ToString() + "분"
    }
    else
    {
        $result = "취약"
        $CV = $count.ToString() + "분"
    }
}
else
{
    $result = "취약"
    $CV = "값이 설정되어 있지 않습니다."
}

# 1) Get-ADDefaultDomainPasswordPolicy 명령어를 입력한다
# 2) LockoutDuration , LockoutObsercationWindow 값을 확인 한다

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title