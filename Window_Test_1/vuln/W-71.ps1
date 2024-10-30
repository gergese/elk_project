###############################################

########### 71. 원격에서 이벤트 로그 파일 접근 차단 ###########

$index = $checklist.check_list[70].code
$title = $checklist.check_list[70].title
$root_title = $checklist.check_list[70].root_title

$RV = "로그 디렉토리의 접근 권한에 Everyone 권한이 없는 경우"
$importance = $checklist.check_list[70].importance

$Everyone_Access = (Get-Permissions -Path "C:\Windows\System32\config" | Where-Object {$_.IdentityReference -like "*Everyone*"}).Count
$Everyone_Access2 = (Get-Permissions -Path "C:\Windows\System32\LogFiles" | Where-Object {$_.IdentityReference -like "*Everyone*"}).Count      

if($Everyone_Access -eq 0 -and $Everyone_Access2 -eq 0)
{
    $result = "양호"
    $CV = "시스템 로그 디렉토리와 IIS 로그 디렉토리에 Everyone 권한이 존재하지 않습니다."
}
else
{
    if($Everyone_Access -gt 0 -and $Everyone_Access2 -gt 0)
    {
        $CV = "시스템 로그 , IIS 로그 디렉토리에 Everyone 권한이 존재합니다."
        $result = "취약"
    }
    elseif($Everyone_Access -gt 0)
    {
        $result = "취약"
        $CV = "시스템 로그에 Everyone 권한이 존재합니다."
    }
    elseif($Everyone_Access2 -gt 0)
    {
        $result = "취약"
        $CV = "IIS 로그 디렉토리에 Everyone 권한이 존재합니다."
    }
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title