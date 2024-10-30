###############################################

############# 2. Guest 계정 상태 ##############

$index = $checklist.check_list[1].code
$title = $checklist.check_list[1].title
$root_title = $checklist.check_list[1].root_title
$importance = $checklist.check_list[1].importance

$var = Get-LocalUser -Name Guest | Select-Object Enabled | Format-Wide

if($var -eq 'True')
{
    $result = "취약"

    $CV = "Guest 계정 활성화"
}
else
{
    $result = "양호"

    $CV = "Guest 계정 비활성화"
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title