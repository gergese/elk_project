###############################################

########### 81. 시작프로그램 목록 분석 ###########

$index = $checklist.check_list[80].code
$title = $checklist.check_list[80].title
$root_title = $checklist.check_list[80].root_title

$RV = "시작 프로그램을 정기적으로 검사한다."
$importance = $checklist.check_list[80].importance

$Start_program_count = (Get-RegistryValue "hkcu\Software\Microsoft\Windows\CurrentVersion\Run" | Select-Object Name, Value | Format-List).count

if ($Start_program_count -eq 0) {
    $result = "양호"
    $CV = "등록된 시작 프로그램이 존재하지 않습니다."
}
else {
    $result = "수동"
    echo("--------------- 시작 프로그램 목록 ---------------") > 81_Start_Program_List.txt
    Get-RegistryValue "hkcu\Software\Microsoft\Windows\CurrentVersion\Run" | Select-Object Name, Value | Format-List >> 81_Start_Program_List.txt

    $CV = "수동 확인"

}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title