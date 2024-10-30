###############################################

########### 13. IIS 상위 디렉토리 접근 금지 ###########

$index = $checklist.check_list[12].code
$title = $checklist.check_list[12].title
$root_title = $checklist.check_list[12].root_title
$importance = $checklist.check_list[11].importance

$Site_List = Get-ChildItem IIS:\Sites | select -expand Name
$count = 0 

$tempSTR = @()

$PSPath = 'MACHINE/WEBROOT/APPHOST'
$Filter = 'system.webServer/asp'
$Name = 'enableParentPaths'

foreach ($Location in $Site_List) {
    # 부모 디렉토리 접근 허용 / 차단 설정한 값을 확인한다.
    $var = Get-WebConfigurationProperty -PSPath $PSPath -Location $Location -Filter $Filter -Name $Name | Select-Object -ExpandProperty Value
    
    if ($var -eq $true) {
        $count++

        $tempSTR += $Location
        $tempSTR += ','

    }
}

if ($tempSTR.count -gt 0) {
    $tempSTR[-1] = ''
}

if ($count -eq 0) {
    $result = "양호"
    $CV = "모든 사이트가 상위 디렉토리 접근 금지가 적용"
}
else {
    $result = "취약"
    $CV = ($tempSTR + " 사이트가 상위 디렉토리 접근 적용")
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title