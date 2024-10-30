###############################################

########### 28. FTP 접근 제어 설정 ###########


$index = $checklist.check_list[27].code
$title = $checklist.check_list[27].title
$root_title = $checklist.check_list[27].root_title
$importance = $checklist.check_list[27].importance

for ($X = 0; $X -lt $FTP_Site_Name_list.count; $X++) {
    $Web_Property_Filter = "/system.ftpserver/security/ipsecurity"
  
    Set-WebConfigurationProperty -Filter $Web_Property_Filter -PSPath $FTP_Site_Path -Name "allowUnlisted" -Value $false
}
  
$CV = "접근제어 설정 적용"
$result = "양호"
  
Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title