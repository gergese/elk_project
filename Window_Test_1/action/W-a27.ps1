###############################################

########### 27. Anonymous FTP 금지 ###########


$index = $checklist.check_list[26].code
$title = $checklist.check_list[26].title
$root_title = $checklist.check_list[26].root_title
$result = "수동"
$importance = $checklist.check_list[26].importance

if ($FTP_Site_List.length -ne 0) {
    for ($X = 0; $X -lt $FTP_Site_Name_list.count; $X++) {
        $Web_Property_Filter = "/system.webServer/security/authentication/anonymousAuthentication"
        Set-WebConfigurationProperty -Filter $Web_Property_Filter -PSPath $FTP_Site_Path_list[$X] -Name enabled -Value $false
    }
    $CV = "익명 연결 허용 x"
    $result = "양호"
}
Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title