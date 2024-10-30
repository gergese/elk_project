######################################################

########### 21. IIS 미사용 스크립트 매핑 제거 ###########


$index = $checklist.check_list[20].code
$title = $checklist.check_list[20].title
$root_title = $checklist.check_list[20].root_title
$RV = "취약한 매핑 존재X"
$importance = $checklist.check_list[20].importance
$total_web_count = 0
$tempSTR = @()

$unsafe_mapping_list = @("*.htr*", "*.idc*", "*.stm*", "*.shtm*", "*.printer*", "*.htw*", "*.ida*", "*.idq*")

for ($X = 0; $X -lt $Site_Name_list.count; $X++) {
    $unsafe_mapping_count = 0

    foreach ($mapping_item in $unsafe_mapping_list) {
        $flag = (Get-WebHandler -PSPath $Site_Path_list[$X] | Where-Object { $_.Path -like ($mapping_item) }).count

        if ($flag -eq 1) {
            $unsafe_mapping_count++

            $mapping_item = $mapping_item.split('*')
            #echo($Site_Name_list[$X] + "사이트 처리기 매핑에 " + "*" + $mapping_item[1] +" 매핑이 등록되어 있습니다. - 취약")
        }
    }

    if ($unsafe_mapping_count -eq 0) {
        #echo($Site_Name_list[$X] + " 사이트에서는 취약한 매핑이 존재하지 않습니다. - 양호`n")
    }
    else {
        $tempSTR += $Site_Name_list[$X]
        $tempSTR += ','

        $total_web_count++
        #echo($Site_Name_list[$X] + " 사이트에서는 총 " + $unsafe_mapping_count +"개의 취약한 매핑이 존재합니다. - 취약`n")
    }
   
}

if ($tempSTR.count -gt 0) {
    $tempSTR[-1] = ''
}

if ($total_web_count -gt 0) {
    $CV = ("취약한 매핑이 존재하는 사이트는 " + $tempSTR + " 입니다.")
    $result = "취약"
}
else {
    $CV = ("모든 사이트에 취약한 매핑 존재X")
    $result = "양호"
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title