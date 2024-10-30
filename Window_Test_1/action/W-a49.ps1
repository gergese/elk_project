﻿###############################################

######## 49. 패스워드 최소 암호 길이 ##########

$index = $checklist.check_list[48].code
$title = $checklist.check_list[48].title
$root_title = $checklist.check_list[48].root_title
$importance = $checklist.check_list[48].importance

# MinimumPasswordLength 항목 찾기
$tempStr = Get-Content $securityTemplatePath | Select-String "MinimumPasswordLength"

$tempStr = $tempStr -replace "MinimumPasswordLength\s*=\s*\d+", "MinimumPasswordLength = 8"

# 파일 내용 전체를 가져와서 수정된 내용을 반영합니다.
$fileContent = Get-Content $securityTemplatePath

# MinimumPasswordLength 라인을 수정합니다.
$fileContent = $fileContent -replace "MinimumPasswordLength\s*=\s*\d+", $tempStr

# 수정된 내용을 파일에 다시 저장
Set-Content -Path $securityTemplatePath -Value $fileContent

$CV = "MinimumPasswordLength 8자로 설정"
$result = "양호"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title