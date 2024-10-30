###############################################

########### 4. 계정 잠금 임계값 설정 ###########

$index = $checklist.check_list[3].code
$title = $checklist.check_list[3].title
$root_title = $checklist.check_list[3].root_title
$importance = $checklist.check_list[3].importance

# ClearTextPassword 항목 찾기
$tempStr = Get-Content $securityTemplatePath | Select-String "LockoutBadCount"

$tempStr = $tempStr -replace "LockoutBadCount\s*=\s*\d+", "LockoutBadCount = 5"

# 파일 내용 전체를 가져와서 수정된 내용을 반영합니다.
$fileContent = Get-Content $securityTemplatePath

# ClearTextPassword 라인을 수정합니다.
$fileContent = $fileContent -replace "LockoutBadCount\s*=\s*\d+", $tempStr

# 수정된 내용을 파일에 다시 저장
Set-Content -Path $securityTemplatePath -Value $fileContent

# 보안 템플릿 임포트
secedit /configure /db $databasePath /cfg $securityTemplatePath

SecEdit /export /cfg $securityTemplatePath

$CV = "LockoutBadCount 5로 변경"
$result = "양호"
Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title