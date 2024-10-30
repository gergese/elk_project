###############################################

###### 56. 콘솔 로그온 시 로컬 계정에서 빈 암호 사용 제한 ######

$index = $checklist.check_list[55].code
$title = $checklist.check_list[55].title
$root_title = $checklist.check_list[55].root_title
$RV = "사용"
$importance = $checklist.check_list[55].importance

$RegPath = "HKLM:SYSTEM\CurrentControlSet\Control\Lsa"
$Name = "LimitBlankPasswordUse"

$var = Get-ItemPropertyValue -Path $RegPath -Name $Name

if($var)
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