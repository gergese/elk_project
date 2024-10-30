###### 7. 공유 권한 및 사용자 그룹 설정 ######

$index = $checklist.check_list[6].code
$title = $checklist.check_list[6].title
$root_title = $checklist.check_list[6].root_title
$importance = $checklist.check_list[6].importance

# 모든 공유 폴더를 가져옵니다
$shares = Get-SmbShare

foreach ($share in $shares) {
    # 공유 폴더의 현재 접근 권한 정보를 가져옵니다.
    $accessList = Get-SmbShareAccess -Name $share.Name
    
    foreach ($access in $accessList) {
        if ($access.AccountName -eq 'Everyone') {
            # Everyone 권한을 제거합니다.
            Revoke-SmbShareAccess -Name $share.Name -AccountName "Everyone" -Force
        }
    }
}

$CV = "Everyone 권한이 모든 공유 폴더에서 제거되었습니다."
$result = "양호"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title