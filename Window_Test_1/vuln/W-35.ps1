###############################################

########### 35. 원격으로 액세스 할 수 있는 레지스트리 경로 ###########

$index = $checklist.check_list[34].code
$title = $checklist.check_list[34].title
$root_title = $checklist.check_list[34].root_title

$RV = "RemoteRegistry Service를 사용하지 않는 경우"
$importance = $checklist.check_list[34].importance

$Service_Status = (Get-Service -Name "RemoteRegistry").Status

if($Service_Status -gt "Running")
{
    $result = "양호"
    $CV = "원격 레지스트리 서비스를 사용하고 있지 않습니다."
}
else
{
    $result = "취약"
    $CV = "원격 레지스트리 서비스를 사용하고 있습니다."      
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title