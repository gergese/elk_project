###############################################

###### 52. 마지막 사용자 이름 표시 안 함 ######

$index = $checklist.check_list[51].code
$title = $checklist.check_list[51].title
$root_title = $checklist.check_list[51].root_title
$RV = "사용"
$importance = $checklist.check_list[51].importance

$RegPath = "HKLM:Software\Microsoft\Windows\CurrentVersion\Policies\System"
$Name = "dontdisplaylastusername"

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