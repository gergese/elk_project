###############################################

########### 59. IIS 웹 서비스 정보 숨김 ###########

$index = $checklist.check_list[58].code
$title = $checklist.check_list[58].title
$root_title = $checklist.check_list[58].root_title
$importance = $checklist.check_list[58].importance

for ($X = 0; $X -lt $Site_Name_list.count; $X++) {
    $Web_Property_Filter = "/system.webserver/httpErrors"
    $Error_Mode = Get-WebConfigurationProperty -Filter $Web_Property_Filter -name errormode -PSPath $Site_Path_list[$X]
    # 오류 모드를 사용자 정의 오류 페이지로 설정
    if ($Error_Mode -ne "Custom") {
        Set-WebConfigurationProperty -Filter $Web_Property_Filter -PSPath $Site_Path_list[$X] -Name "errorMode" -Value "Custom"
        Write-Host "[$($Site_Name_list[$X])] 사용자 정의 오류 페이지로 변경됨."
    }
}
  
$CV = "사용자 정의 오류 페이지로 정의"
$result = "양호"
  
Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title