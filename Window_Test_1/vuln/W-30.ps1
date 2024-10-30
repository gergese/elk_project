###############################################

########### 30. 최신 서비스 팩 적용 ###########

$index = $checklist.check_list[29].code
$title = $checklist.check_list[29].title
$root_title = $checklist.check_list[29].root_title
$RV = "IIS 사용X / Windows 2000 서비스팩 4, Windows 2003 서비스팩 2 이상 설치 / Default 웹 사이트에 MSADC 가상 디렉토리 존재X"
$importance = $checklist.check_list[29].importance

$WIn_version = [Environment]::OSVersion.Version | Select-Object Major | Format-Wide
$WIn_version = String $WIn_version
$WIn_version = $WIn_version -as [int]

if($WIn_version -ge 6)
{
    $result = "양호"
    $CV = "윈도우 2008 이상 OS 버전"
}

else
{
    $result = "수동"
    $CV = "윈도우 2003 이하 OS 버전"
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title