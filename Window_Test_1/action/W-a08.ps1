###############################################

###### 8. 하드디스크 기본 공유 제거 ######

$index = $checklist.check_list[7].code
$title = $checklist.check_list[7].title
$root_title = $checklist.check_list[7].root_title
$importance = $checklist.check_list[7].importance

# 레지스트리 경로 정의
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters"

# 기본 공유 폴더 공유 중지 설정 (자동 관리 공유 비활성화)
Set-ItemProperty -Path $regPath -Name "AutoShareWks" -Value 0 -Force
Set-ItemProperty -Path $regPath -Name "AutoShareServer" -Value 0 -Force

# 메시지 출력
$CV = "기본 공유 폴더가 비활성화되었습니다. 시스템을 재부팅해야 변경 사항이 적용됩니다."
$result = "양호"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title