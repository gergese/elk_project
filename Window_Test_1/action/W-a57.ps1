###############################################

###### 57. 원격터미널 접속 가능한 사용자 그룹 제한 ######

$index = $checklist.check_list[56].code
$title = $checklist.check_list[56].title
$root_title = $checklist.check_list[56].root_title
$importance = $checklist.check_list[56].importance

$result = "수동"
$CV = "관리자가 아닌 별도의 원격접속 계정을 생성해 주세요"
    
Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title
# 보안 템플릿 임포트
secedit /configure /db $databasePath /cfg $securityTemplatePath

SecEdit /export /cfg $securityTemplatePath
