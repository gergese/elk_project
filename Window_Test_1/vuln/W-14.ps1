﻿###############################################

########### 14. IIS 불필요한 파일 제거 ##########

# 진단 대상 Windows 2000, 2003이라 제외

# IIS 7.0 (Windows 2008) 이상 버전 해당 없음

$index = $checklist.check_list[13].code
$title = $checklist.check_list[13].title
$root_title = $checklist.check_list[13].root_title
$RV = "IISSamples, IIS Help 가상 디렉토리 제거"
$importance = $checklist.check_list[13].importance

if ($IIS_version -lt 7) {
    $CV = "수동 확인 후 존재 시 삭제"
    $result = "수동"
}
if ($IIS_version -ge 7) {
    $CV = "대상X"
    $result = "양호"
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title