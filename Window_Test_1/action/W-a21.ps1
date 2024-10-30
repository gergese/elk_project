######################################################

########### 21. IIS 미사용 스크립트 매핑 제거 ###########


$index = $checklist.check_list[20].code
$title = $checklist.check_list[20].title
$root_title = $checklist.check_list[20].root_title
$importance = $checklist.check_list[20].importance

$unsafe_mapping_list = @("*.htr*", "*.idc*", "*.stm*", "*.shtm*", "*.printer*", "*.htw*", "*.ida*", "*.idq*")

for ($X = 0; $X -lt $Site_Name_list.count; $X++) {
    # 각 사이트의 경로를 가져옴
    $sitePath = $Site_Path_list[$X]

    foreach ($mapping_item in $unsafe_mapping_list) {
        # 특정 매핑을 검색
        $handlers = Get-WebHandler -PSPath $sitePath | Where-Object { $_.Path -like $mapping_item }

        # 매핑이 존재하면 제거
        if ($handler.Name) {
            # Name이 null이 아닐 경우에만 제거
            Remove-WebHandler -PSPath $sitePath -Name $handler.Name -Force
        }
    }
}

$CV = "미사용 스크립트 매핑 제거"
$result = "양호"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title