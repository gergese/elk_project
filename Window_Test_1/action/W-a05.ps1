###############################################

###### 5. 해독 가능한 암호화를 사용하여 암호 저장 해제 ######

$index = $checklist.check_list[4].code
$title = $checklist.check_list[4].title
$root_title = $checklist.check_list[4].root_title
$importance = $checklist.check_list[4].importance

$tempStr = Get-Content $securityTemplatePath | Select-String "PasswordComplexity"
# 값 가져오기
$tempStr = $tempStr -replace "PasswordComplexity\s*=\s*\d+", "PasswordComplexity = 5"
    
# 파일 내용 전체를 가져와서 수정된 내용을 반영합니다.
$fileContent = Get-Content $securityTemplatePath
    
# PasswordComplexity 라인을 수정합니다.
$fileContent = $fileContent -replace "PasswordComplexity\s*=\s*\d+", $tempStr
    
# 수정된 내용을 파일에 다시 씁니다.
Set-Content -Path $securityTemplatePath -Value $fileContent
    
$CV = "해독 가능한 암호화를 사용하여 암호 저장 '사용 안 함' 설정"
$result = "양호"
    
Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title