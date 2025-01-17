﻿###############################################

########### 79. 파일 및 디렉토리 보호 ###########

$index = $checklist.check_list[78].code
$title = $checklist.check_list[78].title
$root_title = $checklist.check_list[78].root_title

$RV = "NTFS 파일 시스템을 사용"
$importance = $checklist.check_list[78].importance

$tempSTR = @()

$Not_NTFS_Count = @(Get-Volume | Where-Object { $_.OperationalStatus -eq "OK" } | Where-Object { $_.DriveLetter } | Where-object { ($_.FileSystemType -eq "NTFS") -and ($_.FileSystemType -eq "Unknown") }).Count

if ($Not_NTFS_Count -gt 0) {
    $result = "양호"
    
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