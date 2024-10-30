###############################################

########### 20. IIS 데이터 파일 ACL 적용 ###########


$index = $checklist.check_list[19].code
$title = $checklist.check_list[19].title
$root_title = $checklist.check_list[19].root_title
$importance = $checklist.check_list[19].importance

#$IIS_Site_List = Get-IISSite | select-Object Name
for ($X = 0; $X -lt $Site_Name_list.count; $X++) {
    # 각 사이트 경로에서 모든 파일 및 디렉토리를 재귀적으로 가져옴
    $Path_child_items = (Get-ChildItem -Path $Site_Path_list[$X] -Recurse).FullName
    
    foreach ($file_item in $Path_child_items) {
        # 파일 또는 폴더의 권한 정보 가져오기
        $acl = Get-Acl -Path $file_item
        
        # Everyone 권한 필터링
        $everyone_acl = $acl.Access | Where-Object { $_.IdentityReference -eq "Everyone" }
        
        foreach ($rule in $everyone_acl) {
            # Everyone 권한 제거
            $acl.RemoveAccessRule($rule)
        }
            
        # 변경된 권한을 파일에 적용
        Set-Acl -Path $file_item -AclObject $acl
        Write-Host "Everyone 권한이 제거되었습니다: $file_item"
    }
}

$CV = "Everyone 권한 제거"
$result = "양호"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title