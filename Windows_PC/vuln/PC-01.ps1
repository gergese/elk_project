######### 1. 패스워드의 주기적 변경 #########

$index = $checklist.check_list[0].code
$title = $checklist.check_list[0].title
$root_title = $checklist.check_list[0].root_title
$importance = $checklist.check_list[0].importance

$tempStr = Get-Content user_rights.inf | Select-String "MaximumPasswordAge = "
$tempStr = Out-String -InputObject $tempStr
$tempStr = $tempStr.Split('=')
$count = $tempStr[-1].Trim()

# 추가 체크 항목
$passwordNeverExpires = Get-Content user_rights.inf | Select-String "PasswordNeverExpires = "
$passwordNeverExpires = Out-String -InputObject $passwordNeverExpires
$passwordNeverExpires = $passwordNeverExpires.Split('=')[-1].Trim()

$accountDisabled = Get-Content user_rights.inf | Select-String "AccountDisabled = "
$accountDisabled = Out-String -InputObject $accountDisabled
$accountDisabled = $accountDisabled.Split('=')[-1].Trim()

$minimunPasswordAge = Get-Content user_rights.inf | Select-String "MinimumPasswordAge"
$minimunPasswordAge = Out-String -InputObject $minimunPasswordAge
$minimunPasswordAge = $minimunPasswordAge.Split('=')
$minimunPasswordAge = $minimunPasswordAge[-1].Trim()

$PasswordHistorySize = Get-Content user_rights.inf | Select-String "PasswordHistorySize"
$PasswordHistorySize = Out-String -InputObject $PasswordHistorySize
$PasswordHistorySize = $PasswordHistorySize.Split('=')
$PasswordHistorySize = $PasswordHistorySize[-1].Trim()

$result = "양호"

# 기본 검사 로직
if($count)
{
    if($count -le 90 -and $count -ne 0)
    {
        $CV ="최대 사용기간 : " + $count.Trim() + "일, "
    }
    else
    {
        $result = "취약"
        $CV = "최대 사용기간 : " + $count.Trim() + "일, "
    }
}
else
{
    $result = "취약"
    $CV = "최대 사용 기간이 설정되어 있지 않습니다."
}

# 추가 검사 로직
if($passwordNeverExpires -eq "1")
{
    $result = "취약"
    $CV += " / 암호 사용 기간 제한 없음 체크됨, "
}
if($accountDisabled -eq "1")
{
    $result = "취약"
    $CV += " / 계정 사용 안함 체크됨, "
}


if($minimunPasswordAge)
{
    if($minimunPasswordAge -gt 0)
    {
        $CV += "최소 사용기간 : $minimunPasswordAge 일"
    }
    else
    {
        $result = "취약"
        $CV += "최소 사용기간 :$minimunPasswordAge 일"
    }
}
else
{
    $result = "취약"
    $CV += "최소 암호 기간 미 설정"
}


if($PasswordHistorySize)
{
    if($PasswordHistorySize -ge 24)
    {
        $CV += "최근 암호 기억 : " + $PasswordHistorySize + "개"
    }
    else
    {
        $result = "취약"
        $CV += "최근 암호 기억 : " + $PasswordHistorySize + "개"
    }
}
else
{
    $result = "취약"
    $CV = "해당 옵션이 설정되어 있지 않습니다."
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title