###############################################

########### 73. 사용자가 프린터 드라이버를 설치할 수 없게 함 ###########

$index = $checklist.check_list[72].code
$title = $checklist.check_list[72].title
$root_title = $checklist.check_list[72].root_title

$RV = "해당 정책을 사용 하는 경우"
$importance = $checklist.check_list[72].importance

$flag = (Get-RegistryValue "HKLM\SYSTEM\CurrentControlSet\Control\Print\Providers\LanMan Print Services\Servers" | Where-Object { $_.Name -eq "AddPrinterDrivers" }).Value
    
if ($flag -eq 1) {
    $result = "양호"
    $CV = "'사용자가 프린터 드라이버를 설치할 수 없게 함' 기능을 사용하는 중입니다."
}
else {
    $result = "취약"
    $CV = "'사용자가 프린터 드라이버를 설치할 수 없게 함' 기능을 사용하지 않습니다."
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title