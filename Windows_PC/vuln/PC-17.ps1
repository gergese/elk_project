###############################################

############## 17. 대상 시스템이 Windows 서버를 제외한 다른 OS로 멀티 부팅이 가능하지 않도록 설정 ##############

$index = $checklist.check_list[16].code
$title = $checklist.check_list[16].title
$root_title = $checklist.check_list[16].root_title
$importance = $checklist.check_list[16].importance

$bcdeditResult = bcdedit
$bootLoaderCount = ($bcdeditResult | Select-String "부팅 로더").Count

if ($bootLoaderCount -eq 1) {
    $CV = "양호"
    $result = "PC 내에 하나의 OS만 설치됨" 
}
else {
    $CV = "취약"
    $result = "PC 내에 2개 이상의 OS가 설치됨"
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title