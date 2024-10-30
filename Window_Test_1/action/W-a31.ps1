###############################################

########### 31. 최신 서비스 팩 적용 ###########

$index = $checklist.check_list[30].code
$title = $checklist.check_list[30].title
$root_title = $checklist.check_list[30].root_title
$result_act = $false
$RV = "최신 서비스 팩이 설치"
$importance = $checklist.check_list[30].importance

# CIM을 통해 시스템에 설치된 업데이트 정보 가져오기
$updates = Get-CimInstance -ClassName Win32_QuickFixEngineering

# 업데이트 목록이 존재하는지 확인
if ($updates.Count -gt 0) {
    $result = "수동"
    $CV = "윈도우 서비스 팩이 최신 버전이 아닙니다."
} else {
    $result = "양호"
    $CV = "윈도우 서비스 팩이 최신 버전입니다."
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title