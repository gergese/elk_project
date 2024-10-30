###############################################

########### 58. 터미널 서비스 암호화 수준 설정 ###########

$index = $checklist.check_list[57].code
$title = $checklist.check_list[57].title
$root_title = $checklist.check_list[57].root_title
$importance = $checklist.check_list[57].importance

# 레지스트리 키 경로 및 값 설정
$key = "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp"
$valueName = "MinEncryptionLevel"
$newValue = 2

# 레지스트리 값을 설정
Set-ItemProperty -Path $key -Name $valueName -Value $newValue

$CV = "MinEncryptionLevel 2로 설정"
$result = "양호"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title