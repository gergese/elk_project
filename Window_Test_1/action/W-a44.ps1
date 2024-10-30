###############################################

########### 44.이동식 미디어 포맷 및 꺼내기 허용 ###########

$index = $checklist.check_list[43].code
$title = $checklist.check_list[43].title
$root_title = $checklist.check_list[43].root_title

$importance = $checklist.check_list[43].importance

# 레지스트리 경로 설정
$regPath = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon"
$keyName = "AllocateDASD"

# 현재 값 확인
$currentValue = Get-ItemProperty -Path $regPath -Name $keyName -ErrorAction SilentlyContinue

if ($currentValue) {
    # 값이 존재하면 0으로 설정
    Set-ItemProperty -Path $regPath -Name $keyName -Value 0
}

$CV = "AllocateDASD 값 0으로 설정"
$result = "양호"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title