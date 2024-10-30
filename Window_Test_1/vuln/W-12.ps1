###############################################

######### 12. IIS CGI 실행 제한 양호 #########

$index = $checklist.check_list[11].code
$title = $checklist.check_list[11].title
$root_title = $checklist.check_list[11].root_title
$importance = $checklist.check_list[11].importance

# IIS가 구동 중인지 확인
if ((Get-Service -Name 'W3SVC').Status -eq 'Running') {
    $var = Test-Path -Path "C:\inetpub\scripts"
    if (!$var) {
        $result = "양호"
        $CV = "CGI 디렉토리 존재 X"
    }
    else {
        $access_info = Get-SmbShare | Where-Object { $_.Name -eq "script" } | Where-Object { $_.AccountName -like 'Everyone' }
    
        if ($access_info.length -gt 0) {
            $result = "취약"
            $CV = "Everyone 권한이 존재"
        }
        else {
            $result = "양호"
            $CV = "Everyone 권한이 존재하지 않음"
            $access_info = Get-SmbShareAccess | Where-Object { $_.Name -eq "script" } | Format-wide
        }
    }    
}
else {
    $result = "양호"
    $CV = "IIS 서비스 미사용"
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title