$root_title = $checklist.check_list[0].root_title
$index = $checklist.check_list[0].code
$title = $checklist.check_list[0].title
$importance = $checklist.check_list[0].importance
###### 1. Administrator 계정 이름 바꾸기 ######   

# 변경할 계정 이름 설정
$oldAdminName = "Administrator"
$newAdminName = "KISIA"  # 새 계정 이름 설정

# 관리자 계정이 존재하는지 확인
$adminAccount = Get-LocalUser -Name $oldAdminName

if ($adminAccount) {
    # 계정 이름 변경
    Rename-LocalUser -Name $oldAdminName -NewName $newAdminName
    $CV = "관리자 계정 이름이 '$oldAdminName'에서 '$newAdminName'으로 변경되었습니다."
    $result = "양호"
}
else {
    $CV = "관리자 계정 미 존재"
    $result = "취약"
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title