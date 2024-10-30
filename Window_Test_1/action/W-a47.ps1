###############################################

########### 47. 계정 잠금 기간 설정 ###########

$index = $checklist.check_list[46].code
$title = $checklist.check_list[46].title
$root_title = $checklist.check_list[46].root_title
$importance = $checklist.check_list[46].importance

# LockoutDuration 항목 찾기
$tempStr = Get-Content $securityTemplatePath | Select-String "LockoutDuration"

$tempStr = $tempStr -replace "LockoutDuration\s*=\s*\d+", "LockoutDuration = 60"

# 파일 내용 전체를 가져와서 수정된 내용을 반영합니다.
$fileContent = Get-Content $securityTemplatePath

# LockoutDuration 라인을 수정합니다.
$fileContent = $fileContent -replace "LockoutDuration\s*=\s*\d+", $tempStr

# 수정된 내용을 파일에 다시 저장
Set-Content -Path $securityTemplatePath -Value $fileContent

$CV = "LockoutDuration 60으로 변경"
$result = "양호"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title