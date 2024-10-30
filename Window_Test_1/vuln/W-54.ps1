###############################################

###### 54. 익명 SID/ 이름 변환 허용 해제  ######

$index = $checklist.check_list[53].code
$title = $checklist.check_list[53].title
$root_title = $checklist.check_list[53].root_title
$RV = "사용 안 함"
$importance = $checklist.check_list[53].importance

$flag = (Get-content ./user_rights.inf | Select-String "LSAAnonymousNameLookup" | Select-String "0").count

if($flag -eq 0)
{
    $result = "취약"
    $CV = "해당 옵션 사용 중"

}
else
{
    $result = "양호"
    $CV = "해당 옵션 사용 안 함"
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title