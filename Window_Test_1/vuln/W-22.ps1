###############################################

########### 22. IIS Exec 명령어 쉘 호출 진단 ###########

$index = $checklist.check_list[21].code
$title = $checklist.check_list[21].title
$root_title = $checklist.check_list[21].root_title

$RV = "IIS 5미만 - REG값 0 / IIS 6이상"
$importance = $checklist.check_list[21].importance

# IIS 6.0 (Windows 2003) 이상 버전 해당 없음

if($IIS_version -lt 6)
{
    $CV = "수동 확인"
    $result = "수동"
}
elseif($IIS_version -ge 5)
{
    $CV = "해당 취약점은 IIS 6.0 이상은 해당되지 않습니다"
    $result = "양호"
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title