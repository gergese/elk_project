########### 26. FTP 디렉토리 접근권한 설정 ###########

$index = $checklist.check_list[25].code
$title = $checklist.check_list[25].title
$root_title = $checklist.check_list[25].root_title
$importance = $checklist.check_list[25].importance

for ($X = 0; $X -lt $FTP_Site_Name_list.count; $X++) {
    # FTP 사이트 경로
    $currentPath = $FTP_Site_Path_Full_Path_list[$X]
          
    # 파일 및 디렉터리의 현재 권한을 가져옴
    $acl = Get-Acl -Path $currentPath
          
    # Everyone 권한이 있는 항목을 필터링
    $acl.Access | Where-Object { $_.IdentityReference -like "*Everyone*" } | ForEach-Object {
  
        # Everyone 권한을 제거
        $acl.RemoveAccessRule($_)
              
        # 변경된 ACL을 해당 경로에 다시 설정
        Set-Acl -Path $currentPath -AclObject $acl
    }
}
  
$CV = "Everyone 권한 제거"
$result = "양호"
  
Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title