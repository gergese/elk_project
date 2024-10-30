###############################################

############# 53. 로컬 로그온 허용 ############

$index = $checklist.check_list[52].code
$title = $checklist.check_list[52].title
$root_title = $checklist.check_list[52].root_title
$importance = $checklist.check_list[52].importance

# 파일 내용 전체를 가져옵니다.
$fileContent = Get-Content $securityTemplatePath

# SeInteractiveLogonRight 항목을 찾고, 새로운 값으로 변경합니다.
$fileContent = $fileContent -replace "SeInteractiveLogonRight\s*=\s*\*S-1-5.*", "SeInteractiveLogonRight = *S-1-5-32-544,*S-1-5-32-568"

# 수정된 내용을 파일에 다시 저장합니다.
Set-Content -Path $securityTemplatePath -Value $fileContent

$CV = "SeInteractiveLogonRight 값이 새로운 SID로 변경되었습니다."
$result = "양호"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title
# 보안 템플릿 임포트
secedit /configure /db $databasePath /cfg $securityTemplatePath

SecEdit /export /cfg $securityTemplatePath
