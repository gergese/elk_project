###############################################

########### 74. 세션 연결을 중단하기 전에 필요한 유휴시간 ###########

$index = $checklist.check_list[73].code
$title = $checklist.check_list[73].title
$root_title = $checklist.check_list[73].root_title
$importance = $checklist.check_list[73].importance

# 레지스트리 경로 설정
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters"
$keyName = "enableforcedlogoff"
$keyName2 = "autodisconnect"

# 현재 값 확인
$currentValue_active = Get-ItemProperty -Path $regPath -Name $keyName -ErrorAction SilentlyContinue
$currentValue_time = Get-ItemProperty -Path $regPath -Name $keyName2 -ErrorAction SilentlyContinue

if ($currentValue_active) {
    # 값이 존재하면 1로 설정
    Set-ItemProperty -Path $regPath -Name $keyName -Value 1
}

if ($currentValue_time) {
  # 값이 존재하면 15분으로 설정
  Set-ItemProperty -Path $regPath -Name $keyName2 -Value 15
}

$CV = "enableforcedlogoff 값 1, autodisconnect 값 15로 설정"
$result = "양호"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title