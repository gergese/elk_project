###############################################

########### 25. FTP 서비스 구동 점검 ###########


$index = $checklist.check_list[24].code
$title = $checklist.check_list[24].title
$root_title = $checklist.check_list[24].root_title
$RV = "FTP 사용X or secure FTP 사용"
$importance = $checklist.check_list[24].importance

$flag = (Get-Service | Where-Object { $_.Name -like "*Microsoft FTP Service*" -and $_.Status -eq "Running" }).Count

if ($flag -gt 0) {
    $result = "취약"
    $CV = "FTP 서비스를 사용 중 입니다."
}
else {
    $result = "양호"
    $CV = "FTP 서비스를 사용하지 않습니다."
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title