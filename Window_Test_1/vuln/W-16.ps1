###############################################

########### 16. IIS 링크 사용 금지 ###########


$index = $checklist.check_list[15].code
$title = $checklist.check_list[15].title
$root_title = $checklist.check_list[15].root_title
$importance = $checklist.check_list[15].importance
$RV = "바로가기(.lnk) 파일의 사용 허용X"

$total_web_count = 0
$total_lnk_count = 0
$tempSTR = @()

for ($X = 0; $X -lt $Site_Name_list.count; $X++) {
    $lnk_count = (Get-ChildItem $Site_Path_list[$X] -Recurse | Where-Object { $_.Name -like "*.lnk" }).count

    if ($lnk_count -gt 0) {
        $total_web_count++
        $total_lnk_count += $lnk_count

        $tempSTR += $Site_Name_list[$X]
        $tempSTR += ','
    }

}

if ($tempSTR.count -gt 0) {
    $tempSTR[-1] = ''
}

if ($total_web_count -gt 0) {
    $result = "취약"
    $CV = ("lnk파일 존재 사이트는 " + $tempSTR + " 입니다.")
}
else {
    $result = "양호"
    $CV = "모든 사이트에 lnk 파일이 존재하지 않습니다."
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title