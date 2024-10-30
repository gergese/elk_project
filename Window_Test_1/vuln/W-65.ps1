###############################################

########### 65. Telnet 보안 설정 ###########

$index = $checklist.check_list[64].code
$title = $checklist.check_list[64].title
$root_title = $checklist.check_list[64].root_title

$RV = "Telnet 서비스를 사용하지 않을 때"
$importance = $checklist.check_list[64].importance

if((Get-Service -Name "*telnet*").count -gt 0)
{
    $result = "취약"
    $CV = "telnet 서비스를 사용하고 있습니다."
}
else
{
    $result = "양호"
    $CV = "telnet 서비스를 사용하지 않습니다."
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title