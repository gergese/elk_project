###############################################

########### 35. 원격으로 액세스 할 수 있는 레지스트리 경로 ###########

$index = $checklist.check_list[34].code
$title = $checklist.check_list[34].title
$root_title = $checklist.check_list[34].root_title
$importance = $checklist.check_list[34].importance

# RemoteRegistry 서비스 가져오기
$service = Get-Service -Name "RemoteRegistry"

# 서비스 중지
if ($service.Status -eq 'Running') {
  Stop-Service -Name "RemoteRegistry" -Force
}

# 서비스 시작 유형을 '사용 안 함'으로 설정
Set-Service -Name "RemoteRegistry" -StartupType Disabled

$CV = "RemoteRegistry '사용 안 함'으로 설정"
$result = "양호"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title