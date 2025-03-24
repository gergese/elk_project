###############################################

########### 13. CD, DVD, USB 메모리 등과 같은 미디어의 자동실행 방지등 이동식 미디어에 대한 보안대책 수립 ###########

$index = $checklist.check_list[12].code
$title = $checklist.check_list[12].title
$root_title = $checklist.check_list[12].root_title
$importance = $checklist.check_list[12].importance

$drivesAutoRun = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoDriveTypeAutoRun -ErrorAction SilentlyContinue| Select-Object -ExpandProperty NoDriveTypeAutoRun
if($drivesAutoRun -eq 255) {
    $CV = "양호"
    $result = "모든 드라이브 자동 실행 제한 설정 됨"
}
else {
    $CV = "취약"
    $result = "모든 드라이브 자동 실행 제한 설정 되지 않음"
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title