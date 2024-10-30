###############################################

########### 59. IIS 웹 서비스 정보 숨김 ###########

$index = $checklist.check_list[58].code
$title = $checklist.check_list[58].title
$root_title = $checklist.check_list[58].root_title
$RV = "웹 서비스의 에러 페이지를 별도로 지정한다."
$importance = $checklist.check_list[58].importance

$total_web_count = 0

$tempSTR = @()

for($X=0;$X -lt $Site_Name_list.count;$X++)
{
    $Web_Property_Filter = "/system.webserver/httpErrors"
    $Error_Mode = Get-WebConfigurationProperty -Filter $Web_Property_Filter -name errormode -PSPath $Site_Path_list[$X]

    if($Error_Mode -like "*DetailedLocalOnly*")
    {
        $result = "취약"
        $total_web_count++
        $tempSTR += $Site_Name_list[$X]
        $tempSTR += ','
    }
    elseif($Error_Mode -like "Detailed")
    {
        $result = "취약"
        $total_web_count++
        $tempSTR += $Site_Name_list[$X]
        $tempSTR += ','
    }
    elseif($Error_Mode -like "*Custom*")
    {
        $result = "양호"
    }

}

if($tempSTR.count -gt 0)
{
    $tempSTR[-1] = ''
}

if($total_web_count -gt 0)
{
    $CV = ("사용자 지정 에러 페이지를 별도로 지정하지 않은 사이트는 " + $tempSTR + "입니다.")
    $result = "취약"
}
else
{
    $CV = ("모든 사이트에 사용자 지정 에러 페이지 지정 설정")
    $result = "양호"
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title