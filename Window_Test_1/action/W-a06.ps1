###############################################

###### 6. 관리자 그룹에 최소한의 사용자 포함 ######

$index = $checklist.check_list[5].code
$title = $checklist.check_list[5].title
$root_title = $checklist.check_list[5].root_title

# 레지스트리 경로와 이름 정의
$RegPath = "HKLM:SYSTEM\CurrentControlSet\Control\Lsa"
$Name = "EveryoneIncludesAnonymous"

# 현재 값 읽기
# $currentValue = Get-ItemPropertyValue -Path $RegPath -Name $Name

# 값을 0으로 변경
Set-ItemProperty -Path $RegPath -Name $Name -Value 0

# 변경 후 확인
$CV = "Everyone 사용 권한을 익명 사용자에게 적용 정책 '사용 안 함' 설정"
$result = "양호"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title