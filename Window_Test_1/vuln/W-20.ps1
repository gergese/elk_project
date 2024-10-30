###############################################

########### 20. IIS 데이터 파일 ACL 적용 ###########


$index = $checklist.check_list[19].code
$title = $checklist.check_list[19].title
$root_title = $checklist.check_list[19].root_title
$RV = "홈 디렉토리 하위 모든파일에 Everyone 권한 존재X"
$importance = $checklist.check_list[19].importance
$total_web_count = 0

$tempSTR = @()

#$IIS_Site_List = Get-IISSite | select-Object Name
for ($X = 0; $X -lt $Site_Name_list.count; $X++) {
    $Path_child_items = (Get-ChildItem -Path $Site_Path_list[$X] -Recurse).FullName
    $Everyone_Access_files_count = 0

    foreach ($file_item in $Path_child_items) {
        $Everyone_Access_count = (Get-Permissions -Path $file_item | Where-Object { $_.IdentityReference -like "*Everyone*" }).Count

        if ($Everyone_Access_count -gt 0) {
            #해당 사이트 Everyone 권한 허용 파일 갯수 증가
            $Everyone_Access_files_count++

        }
    }

    if ($Everyone_Access_files_count -eq 0) {
        #echo($Site_Name_list[$X] + " 사이트 홈 디렉토리 내부에는 Everyone 권한을 가진 파일이 존재하지 않습니다. - 양호`n")
    }
    else {
        $tempSTR += $Site_Name_list[$X]
        $tempSTR += ','

        $total_web_count++
        #echo($Site_Name_list[$X] + " 사이트 홈 디렉토리에서는 " + "Everyone 권한을 가진 파일이 " + $Everyone_Access_files_count + "개 존재합니다. - 취약")
    }

}

if ($tempSTR.count -gt 0) {
    $tempSTR[-1] = ''
}


if ($total_web_count -gt 0) {
    $CV = ("홈 디렉토리 하위 파일에 Everyone 권한이 존재하는 사이트는 " + $tempSTR + " 입니다.")
    $result = "취약"
}
else {
    $CV = ("모든 사이트의 홈 디렉터리 하위 파일에 Everyone 권한 존재X")
    $result = "양호"
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title