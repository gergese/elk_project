###############################################

########### 16. 파일 시스템이 NTFS 포맷으로 설정 ###########

$index = $checklist.check_list[15].code
$title = $checklist.check_list[15].title
$root_title = $checklist.check_list[15].root_title
$importance = $checklist.check_list[15].importance

$tempSTR = @()

$Not_NTFS_Count = @(Get-Volume | Where-Object { $_.OperationalStatus -eq "OK" } | Where-Object { $_.DriveLetter } | Where-object { ($_.FileSystemType -eq "NTFS") -and ($_.FileSystemType -eq "Unknown") }).Count

if ($Not_NTFS_Count -gt 0) {
    $result = "취약"
    
    $Not_NTFS_list = (Get-Volume | Where-Object { $_.OperationalStatus -eq "OK" } | Where-Object { $_.DriveLetter }).DriveLetter | Where-object { $_.FileSystem -ne "NTFS" }
    
    foreach ($item in $Not_NTFS_list) {
        $tempSTR += $item
        $tempSTR += ','
    }

    if ($tempSTR.count -gt 0) {
        $tempSTR[-1] = ''
    }

    $CV = "NTFS 파일 시스템을 사용하지 않는 드라이브는 " + $tempSTR + " 드라이브 입니다."
}
else {
    $result = "양호"
    $CV = "활성화된 드라이브중 NTFS 파일 시스템을 사용하지 않는 드라이브는 없습니다."
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title