###############################################

###### 52. 마지막 사용자 이름 표시 안 함 ######

$index = $checklist.check_list[51].code
$title = $checklist.check_list[51].title
$root_title = $checklist.check_list[51].root_title
$importance = $checklist.check_list[51].importance

# 레지스트리 경로와 이름 정의
$RegPath = "HKLM:Software\Microsoft\Windows\CurrentVersion\Policies\System"
$Name = "dontdisplaylastusername"

# 현재 값 읽기
# $currentValue = Get-ItemPropertyValue -Path $RegPath -Name $Name

# 값을 0으로 변경
Set-ItemProperty -Path $RegPath -Name $Name -Value 0

$CV = "dontdisplaylastusername 0으로 설정"
$result = "양호"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title