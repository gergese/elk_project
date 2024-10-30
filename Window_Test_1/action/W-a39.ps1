###############################################

########### 39. 로그온 하지 않고 시스템 종료 허용 해제 ###########

$index = $checklist.check_list[38].code
$title = $checklist.check_list[38].title
$root_title = $checklist.check_list[38].root_title
$importance = $checklist.check_list[38].importance

# 레지스트리 경로 설정
$regPath = "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$keyName = "shutdownwithoutlogon"

# 값이 0으로 설정
Set-ItemProperty -Path $regPath -Name $keyName -Value 0

# 설정 결과 출력
$updatedValue = (Get-RegistryValue $regPath | Where-Object { $_.Name -eq $keyName }).Value


Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title