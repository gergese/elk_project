########### 37. SAM 파일 접근 통제 설정 ###########

$index = $checklist.check_list[36].code
$title = $checklist.check_list[36].title
$root_title = $checklist.check_list[36].root_title
$importance = $checklist.check_list[36].importance

# 경로 설정
$path = "C:\Windows\System32\config\SAM"

# 현재 ACL 가져오기
$acl = Get-Acl -Path $path

# 제거할 권한 필터링: System과 Administrator를 제외한 모든 권한
$rulesToRemove = $acl.Access | Where-Object { 
    $_.IdentityReference -ne "SYSTEM" -and $_.IdentityReference -ne "Administrators"
}

# 제거할 권한이 있을 경우
if ($rulesToRemove) {
    foreach ($rule in $rulesToRemove) {
        # ACL에서 권한 제거
        $acl.RemoveAccessRule($rule)
    }
    # 수정된 ACL을 다시 설정
    Set-Acl -Path $path -AclObject $acl
}

$CV = "SAM 파일 불필요한 권한 제거"
$result = "양호"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title