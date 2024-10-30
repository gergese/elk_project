###############################################

########### 70. 이벤트 로그 관리 설정 ###########

$index = $checklist.check_list[69].code
$title = $checklist.check_list[69].title
$root_title = $checklist.check_list[69].root_title
$importance = $checklist.check_list[69].importance

# 응용 프로그램 로그 설정
# 레지스트리 경로 설정
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\Application"

# 보존 설정을 0으로 변경
Set-ItemProperty -Path $regPath -Name "Retention" -Value 0

# 최대 로그 크기를 10240KB (10MB)로 설정
$maxSizeKB = 10240
$maxSizeBytes = $maxSizeKB * 1KB # KB를 바이트로 변환

Set-ItemProperty -Path $regPath -Name "MaxSize" -Value $maxSizeBytes

# 보안 관련 로그 설정
# 레지스트리 경로 설정
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\Security"

# 보존 설정을 0으로 변경
Set-ItemProperty -Path $regPath -Name "Retention" -Value 0

# 최대 로그 크기를 10240KB (10MB)로 설정
$maxSizeKB = 10240
$maxSizeBytes = $maxSizeKB * 1KB # KB를 바이트로 변환

Set-ItemProperty -Path $regPath -Name "MaxSize" -Value $maxSizeBytes

# 시스템 관련 로그 설정
# 레지스트리 경로 설정
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\System"

# 보존 설정을 0으로 변경
Set-ItemProperty -Path $regPath -Name "Retention" -Value 0

# 최대 로그 크기를 10240KB (10MB)로 설정
$maxSizeKB = 10240
$maxSizeBytes = $maxSizeKB * 1KB # KB를 바이트로 변환

Set-ItemProperty -Path $regPath -Name "MaxSize" -Value $maxSizeBytes

$CV = "RemoteRegistry '사용 안 함'으로 설정"
$result = "양호"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title