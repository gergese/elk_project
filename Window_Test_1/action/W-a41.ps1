###############################################

########### 41. 보안 감사를 로그할 수 없는 경우 즉시 시스템 종료 해제 ###########

$index = $checklist.check_list[40].code
$title = $checklist.check_list[40].title
$root_title = $checklist.check_list[40].root_title
$importance = $checklist.check_list[40].importance

# 레지스트리 경로 및 키 설정
$regPath = "HKLM\SYSTEM\CurrentControlSet\Control\Lsa"
$keyName = "crashonauditfail"
$newValue = 0

# 현재 값 확인
$currentValue = Get-ItemProperty -Path $regPath -Name $keyName -ErrorAction SilentlyContinue

if ($currentValue) {
  # 값이 존재하면 0으로 설정
  Set-ItemProperty -Path $regPath -Name $keyName -Value $newValue
}
else {
  # 값이 없으면 추가
  New-ItemProperty -Path $regPath -Name $keyName -Value $newValue -PropertyType DWord
}

$CV = "crashonauditfail값 0으로 설정"
$result = "양호"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title