###############################################

########### 48. 패스워드 복잡성 설정 ##########

$index = $checklist.check_list[47].code
$title = $checklist.check_list[47].title
$root_title = $checklist.check_list[47].root_title
$importance = $checklist.check_list[47].importance

# PasswordComplexity 항목 찾기
$tempStr = Get-Content $securityTemplatePath | Select-String "PasswordComplexity"

$tempStr = $tempStr -replace "PasswordComplexity\s*=\s*\d+", "PasswordComplexity = 1"

# 파일 내용 전체를 가져와서 수정된 내용을 반영합니다.
$fileContent = Get-Content $securityTemplatePath

# PasswordComplexity 라인을 수정합니다.
$fileContent = $fileContent -replace "PasswordComplexity\s*=\s*\d+", $tempStr

# 수정된 내용을 파일에 다시 저장
Set-Content -Path $securityTemplatePath -Value $fileContent

$CV = "PasswordComplexity 사용 설정"
$result = "양호"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title