###############################################

######### 12. IIS CGI 실행 제한 양호 #########

$index = $checklist.check_list[11].code
$title = $checklist.check_list[11].title
$root_title = $checklist.check_list[11].root_title
$importance = $checklist.check_list[11].importance

$var = Test-Path -Path "C:\inetpub\scripts"

# Everyone 권한 제거
icacls $var /remove "Everyone"

$CV = "CGI 스크립트 파일의 Everyone 권한을 제거하였습니다."
$result = "양호"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title