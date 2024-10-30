###############################################

########### 16. IIS 링크 사용 금지 ###########


$index = $checklist.check_list[15].code
$title = $checklist.check_list[15].title
$root_title = $checklist.check_list[15].root_title
$importance = $checklist.check_list[15].importance

for($X=0; $X -lt $Site_Name_list.count; $X++)
{
    # 각 사이트 경로에서 .lnk 파일을 재귀적으로 찾는다
    $lnkFiles = Get-ChildItem $Site_Path_list[$X] -Recurse | Where-Object {$_.Extension -eq ".lnk"}
    
    # 링크 파일이 있으면 삭제한다
    foreach ($file in $lnkFiles) {
        Remove-Item $file.FullName -Force
    }
}

$CV = "바로가기 파일 모두 제거"
$result = "양호"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title