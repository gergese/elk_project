###############################################

########### 40. 원격 시스템에서 강제로 시스템 종료 ###########

$index = $checklist.check_list[39].code
$title = $checklist.check_list[39].title
$root_title = $checklist.check_list[39].root_title

$importance = $checklist.check_list[39].importance

SecEdit /export /cfg $securityTemplatePath

# 파일 내용 전체를 가져옵니다.
$fileContent = Get-Content $securityTemplatePath

# SeRemoteShutdownPrivilege 항목을 수정하여 Administrator만 포함하도록 합니다.
$fileContent = $fileContent -replace "SeRemoteShutdownPrivilege\s*=\s*.*", "SeRemoteShutdownPrivilege = *S-1-5-32-544"  # S-1-5-32-544는 Administrator SID입니다.

# 수정된 내용을 파일에 다시 저장합니다.
Set-Content -Path $securityTemplatePath -Value $fileContent

$CV = "SeRemoteShutdownPrivilege 값 Administrator로 변경"
$result = "양호"

# 보안 템플릿 임포트
secedit /configure /db $databasePath /cfg $securityTemplatePath

SecEdit /export /cfg $securityTemplatePath


Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title