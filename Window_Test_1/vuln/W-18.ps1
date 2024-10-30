###############################################

########### 18. IIS DB 연결 취약점 점검 ###########

$index = $checklist.check_list[17].code
$title = $checklist.check_list[17].title
$root_title = $checklist.check_list[17].root_title
$RV = ".asa 매핑 시 특정 동작 설정 / .asa 매핑 존재X"
$importance = $checklist.check_list[17].importance

$IIS_Site_List = Get-IISSite | select-Object Name
$flag_asa = 0
$flag_asax = 0

$total_web_count = 0

$tempSTR = @()

for ($X = 0; $X -lt $Site_Name_list.count; $X++) {
    $flag_asa = (Get-WebHandler -PSPath $Site_Path_list[$X] | Where-Object { $_.Path -eq "*.asa" }).count
    if ($flag_asa -eq 1) {
        #echo($Site_Name + "사이트 처리기 매핑에 *.asa 매핑이 등록되어 있습니다. - 취약")
    }

    $flag_asax = (Get-WebHandler -PSPath $Site_Path_list[$X] | Where-Object { $_.Path -eq "*.asax" }).count
    if ($flag_asax -eq 1) {
        #echo($Site_Name_list[$X] + "사이트 처리기 매핑에 *.asax 매핑이 등록되어 있습니다. - 취약")
    }

    if ($flag_asa -eq 0 -and $flag_asax -eq 0) {
        #echo($Site_Name_list[$X] + "사이트는 처리기 매핑에 *asa , *.asax 매핑이 모두 등록되어 있지 않습니다. - 양호")
    }
    else {
        $total_web_count++
        $tempSTR += $Site_Name_list[$X]
        $tempSTR += ','    
    }
}

if ($tempSTR.count -gt 0) {
    $tempSTR[-1] = ''
}

if ($total_web_count -gt 0) {
    $result = "취약"
    $CV = ($tempSTR + " 사이트에서 .asa 혹은 .asax 매핑 처리X")
}
else {
    $result = "양호"
    $CV = ("모든 사이트에서 .asa 혹은 .asax 매핑 처리O")
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title