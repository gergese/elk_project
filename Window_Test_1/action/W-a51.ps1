###############################################

######### 51. 패스워드 최소 사용 기간 #########

$index = $checklist.check_list[50].code
$title = $checklist.check_list[50].title
$root_title = $checklist.check_list[50].root_title
$importance = $checklist.check_list[50].importance

# MinimumPasswordAge 항목 찾기
$tempStr = Get-Content $securityTemplatePath | Select-String "MinimumPasswordAge"

$tempStr = $tempStr -replace "MinimumPasswordAge\s*=\s*\d+", "MinimumPasswordAge = 1"

# 파일 내용 전체를 가져와서 수정된 내용을 반영합니다.
$fileContent = Get-Content $securityTemplatePath

# MinimumPasswordAge 라인을 수정합니다.
$fileContent = $fileContent -replace "MinimumPasswordAge\s*=\s*\d+", $tempStr

# 수정된 내용을 파일에 다시 저장
Set-Content -Path $securityTemplatePath -Value $fileContent

$CV = "MinimumPasswordAge 1일로 설정"
$result = "양호"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title