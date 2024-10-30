###############################################

########### 71. 원격에서 이벤트 로그 파일 접근 차단 ###########

$index = $checklist.check_list[70].code
$title = $checklist.check_list[70].title
$root_title = $checklist.check_list[70].root_title
$importance = $checklist.check_list[70].importance

# 경로 목록
$paths = @("C:\Windows\System32\config", "C:\Windows\System32\LogFiles")

foreach ($path in $paths) {
  # ACL 가져오기
  $acl = Get-Acl -Path $path
    
  # Everyone 권한 필터링
  $everyoneAccessRules = $acl.Access | Where-Object { $_.IdentityReference -like "*Everyone*" }

  # Everyone 권한이 있는 경우
  if ($everyoneAccessRules) {
    foreach ($rule in $everyoneAccessRules) {
      # ACL에서 권한 제거
      $acl.RemoveAccessRule($rule)
    }
    # 수정된 ACL을 다시 설정
    Set-Acl -Path $path -AclObject $acl
  }
}

$CV = "RemoteRegistry '사용 안 함'으로 설정"
$result = "양호"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title