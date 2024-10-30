###############################################

############## 55. 최근 암호 기억 ##############

$index = $checklist.check_list[54].code
$title = $checklist.check_list[54].title
$root_title = $checklist.check_list[54].root_title
$importance = $checklist.check_list[54].importance

# PasswordHistorySize 항목 찾기
$tempStr = Get-Content $securityTemplatePath | Select-String "PasswordHistorySize"

$tempStr = $tempStr -replace "PasswordHistorySize\s*=\s*\d+", "PasswordHistorySize = 4"

# 파일 내용 전체를 가져와서 수정된 내용을 반영합니다.
$fileContent = Get-Content $securityTemplatePath

# PasswordHistorySize 라인을 수정합니다.
$fileContent = $fileContent -replace "PasswordHistorySize\s*=\s*\d+", $tempStr

# 수정된 내용을 파일에 다시 저장
Set-Content -Path $securityTemplatePath -Value $fileContent

$CV = "PasswordHistorySize 4로 설정"
$result = "양호"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title