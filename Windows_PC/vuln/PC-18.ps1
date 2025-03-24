###############################################

############## 18. 브라우저 종료 시 임시 인터넷 파일 폴더의 내용을 삭제하도록 설정 ##############

$index = $checklist.check_list[17].code
$title = $checklist.check_list[17].title
$root_title = $checklist.check_list[17].root_title
$importance = $checklist.check_list[17].importance

$emptyFolder = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Cache" -Name Persistent -ErrorAction SilentlyContinue

if($emptyFolder -ne $null) {
    if($emptyFolder.Persistent -eq 0) {
        $CV = "양호"
        $result = "브라우저를 닫을 때 임시 인터넷 파일 폴더 비우기 설정이 사용으로 설정"
    }
    else {
        $CV = "양호"
        $result = "브라우저를 닫을 때 임시 인터넷 파일 폴더 비우기 설정이 미 사용으로 설정"
    }
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title