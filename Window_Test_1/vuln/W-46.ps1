###############################################

###### 46. Everyone 사용권한을 익명사용자에 적용 해제 ######

$index = $checklist.check_list[45].code
$title = $checklist.check_list[45].title
$root_title = $checklist.check_list[45].root_title
$RV = "사용 안 함"
$importance = $checklist.check_list[45].importance

$RegPath = "HKLM:SYSTEM\CurrentControlSet\Control\Lsa"
$Name = "everyoneincludesanonymous"

$var = Get-ItemPropertyValue -Path $RegPath -Name $Name

if(!$var)
{
    $result = "양호"
    $CV = "Everyone 사용권한을 익명사용자에 적용 해제"
}
else
{
    $result = "취약"
    $CV = "Everyone 사용권한을 익명사용자에 적용"
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title