###############################################

########### 11. 디렉토리 리스팅 제거 ###########

$index = $checklist.check_list[10].code
$title = $checklist.check_list[10].title
$root_title = $checklist.check_list[10].root_title
$importance = $checklist.check_list[10].importance

$count = 0 

$tempSTR = @()

# IIS가 구동 중인지 확인
if ((Get-Service -Name 'W3SVC').Status -eq 'Running') {
    $Site_List = Get-ChildItem IIS:\Sites | select -expand Name

    $PSPath = 'MACHINE/WEBROOT/APPHOST'
    $Filter = 'system.webServer/directoryBrowse'
    $Name = 'enabled'
    
    foreach ($Location in $Site_List) {
        # 디렉토리 검색 허용 / 차단 설정한 값을 확인한다.
        $var = (Get-WebConfigurationProperty -PSPath $PSPath -Location $Location -Filter $Filter -Name $Name).Value
    
        if ($var) {
            $tempSTR += $Location
            $tempSTR += ','
    
            $count++
        }
    }
    
    if ($tempSTR.count -gt 0) {
        $tempSTR[-1] = ''
    }
    
    if ($count -eq 0) {   
        $result = "양호"
        $CV = ("모든 사이트에서 디렉토리 검색 차단")
    }
    else {
        $result = "취약"
        $CV = ($tempSTR + "사이트에서 디렉토리 검색 허용")    
    }
}
else {
    $result = "양호"
    $CV = ("IIS 서비스 미사용")
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title