###############################################

###### 54. 익명 SID/ 이름 변환 허용 해제  ######

$index = $checklist.check_list[53].code
$title = $checklist.check_list[53].title
$root_title = $checklist.check_list[53].root_title
$importance = $checklist.check_list[53].importance

# LSAAnonymousNameLookup 항목 찾기
$tempStr = Get-Content $securityTemplatePath | Select-String "LSAAnonymousNameLookup"

$tempStr = $tempStr -replace "LSAAnonymousNameLookup\s*=\s*\d+", "LSAAnonymousNameLookup = 0"

# 파일 내용 전체를 가져와서 수정된 내용을 반영합니다.
$fileContent = Get-Content $securityTemplatePath

# LSAAnonymousNameLookup 라인을 수정합니다.
$fileContent = $fileContent -replace "LSAAnonymousNameLookup\s*=\s*\d+", $tempStr

# 수정된 내용을 파일에 다시 저장
Set-Content -Path $securityTemplatePath -Value $fileContent

$CV = "LSAAnonymousNameLookup 0으로 설정"
$result = "양호"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title