###############################################

########### 2. 패스워드 정책이 해당 기관의 보안 정책에 적합하게 설정 ##########

$index = $checklist.check_list[1].code
$title = $checklist.check_list[1].title
$root_title = $checklist.check_list[1].root_title
$importance = $checklist.check_list[1].importance

$PasswordComplexity = Get-Content user_rights.inf | Select-String "PasswordComplexity"
$PasswordComplexity = Out-String -InputObject $PasswordComplexity
$PasswordComplexity = $PasswordComplexity.Split('=')
$PasswordComplexity = $PasswordComplexity[-1].Trim()

$MinimumPasswordLength = Get-Content user_rights.inf | Select-String "MinimumPasswordLength"
$MinimumPasswordLength = Out-String -InputObject $MinimumPasswordLength
$MinimumPasswordLength = $MinimumPasswordLength.Split('=')
$MinimumPasswordLength = $MinimumPasswordLength[-1].Trim()

$result = "양호"

if($PasswordComplexity)
{
    $CV = "패스워드 복잡성 옵션 사용 중, "
}
else
{
    $result = "취약"
    $CV = "패스워드 복잡성 옵션 사용 안 함"
}


if($MinimumPasswordLength)
{
    if($MinimumPasswordLength -ge 8)
    {
        $CV += "최소 패스워드 길이 : " + $MinimumPasswordLength + "자, "
    }
    else
    {
        $result = "취약"
        $CV += "최소 패스워드 길이 : " + $MinimumPasswordLength + "자, "
    }
}
else
{
    $result = "취약"
    $CV += "최소 패스워드 길이 미 설정, "
}


Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title