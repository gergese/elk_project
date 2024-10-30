###############################################

######### 50. 패스워드 최대 사용 기간 #########

$index = $checklist.check_list[49].code
$title = $checklist.check_list[49].title
$root_title = $checklist.check_list[49].root_title
$importance = $checklist.check_list[49].importance

# 파일 경로 정의
$securityTemplatePath = ".\user_rights.inf"

# 파일 내용 전체를 가져옵니다.
$fileContent = Get-Content $securityTemplatePath

# 첫 번째 'MaximumPasswordAge' 항목 찾기
$firstMatch = $fileContent | Select-String -Pattern "MaximumPasswordAge" | Select-Object -First 1

# 첫 번째 'MaximumPasswordAge'의 인덱스 찾기
$firstMatchIndex = $fileContent.IndexOf($firstMatch.Line)

# 첫 번째 'MaximumPasswordAge' 값을 원하는 값으로 변경 (예: 90일로 설정)
$fileContent[$firstMatchIndex] = $fileContent[$firstMatchIndex] -replace "MaximumPasswordAge\s*=\s*\d+", "MaximumPasswordAge = 90"

# 수정된 내용을 파일에 다시 저장합니다.
Set-Content -Path $securityTemplatePath -Value $fileContent

$CV = "첫 번째 MaximumPasswordAge 값이 90으로 변경되었습니다."
$result = "양호"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title
# 보안 템플릿 임포트
secedit /configure /db $databasePath /cfg $securityTemplatePath
SecEdit /export /cfg $securityTemplatePath
