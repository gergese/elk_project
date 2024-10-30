########### 36. 백신 프로그램 설치 ###########
$index = $checklist.check_list[35].code
$title = $checklist.check_list[35].title
$root_title = $checklist.check_list[35].root_title

$importance = $checklist.check_list[35].importance
$result = "수동"
$CV = "SAM 파일의 권한이 SYSTEM / Administrator 계정에만 부여되어 있습니다."

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title