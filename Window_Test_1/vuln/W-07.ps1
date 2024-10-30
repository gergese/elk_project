###### 7. 공유 권한 및 사용자 그룹 설정 ######

$index = $checklist.check_list[6].code
$title = $checklist.check_list[6].title
$root_title = $checklist.check_list[6].root_title
$importance = $checklist.check_list[6].importance

# 모든 공유 폴더 중 Everyone으로 공유 된 폴더 정보를 조회
$SmbShareInfo = @(Get-SmbShare | foreach { Get-SmbShareAccess -Name $_.Name } | Where-Object { $_.AccountName -like 'Everyone' })
$var = $SmbShareInfo.Length
$CV = @()

$temp = $SmbShareInfo.Name

if ($var -gt 0) {
    $result = "취약"
    foreach ($item in $temp) {
        $CV += ($item + ',')
    }
    $CV[-1] = "공유 폴더가 Everyone 권한으로 공유 중"

}
else {
    $result = "양호"
    $CV = "Everyone 권한이 있는 공유 폴더 존재X"
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title