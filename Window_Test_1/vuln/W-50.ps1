###############################################

######### 50. 패스워드 최대 사용 기간 #########

$index = $checklist.check_list[49].code
$title = $checklist.check_list[49].title
$root_title = $checklist.check_list[49].root_title
$RV = "90(일)이하"
$importance = $checklist.check_list[49].importance

$tempStr = Get-Content user_rights.inf | Select-String "MaximumPasswordAge = "
$tempStr = Out-String -InputObject $tempStr
$tempStr = $tempStr.Split('=')
$count = $tempStr[-1].Trim()

if($count)
{
    if($count -le 90 -and $count -ne 0)
    {
        $result = "양호"
        $CV = $count
        $CV = $CV.Trim()
        $CV += "일"
    }
    else
    {
        $result = "취약"
        $CV = $count
        $CV = $CV.Trim()
        $CV += "일"
    }
}
else
{
    $result = "취약"
    $CV = "해당 옵션이 설정되어 있지 않습니다."
}

# 1) Get-ADDefaultDomainPasswordPolicy 명령어를 입력한다
# 2) MaxPasswordAge 값을 확인한다

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title