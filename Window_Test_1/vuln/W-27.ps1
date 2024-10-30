###############################################

########### 27. Anonymous FTP 금지 ###########


$index = $checklist.check_list[26].code
$title = $checklist.check_list[26].title
$root_title = $checklist.check_list[26].root_title
$RV = "FTP 서비스 사용X or 익명 연결 허용 옵션을 해제"
$importance = $checklist.check_list[26].importance

$total_web_count = 0

$tempSTR = @()

# FTP 사이트가 존재할 경우
if($FTP_Site_List.length -ne 0)
{
    for($X=0;$X -lt $FTP_Site_Name_list.count;$X++)
    {
        $Web_Property_Filter = "/system.webServer/security/authentication/anonymousAuthentication"

        $Everyone_Access = Get-WebConfigurationProperty -Filter $Web_Property_Filter -name enabled  -PSPath $FTP_Site_Path_list[$X] | Select-Object "Value"

        if($Everyone_Access -like "*True*")
        {
            $total_web_count++
            $tempSTR += $FTP_Site_Name_list[$X]
            $tempSTR += ','
        }

    }
    
    if($tempSTR.count -gt 0)
    {
        $tempSTR[-1] = ''
    }

    if($total_web_count -gt 0)
    {
        $result = "취약"
        $CV = ("Anonymous 로그인이 허용된 FTP 사이트는 " + $tempSTR + " 입니다.")
    }
    else
    {
        $result = "양호"
        $CV = ("홈 디렉토리에 Everyone 권한이 존재하는 FTP 사이트는 없습니다.")
    }
}
# FTP 사이트가 존재하지 않을 경우
else
{
    $result = "양호"
    $CV = "FTP 사이트를 사용하지 않습니다."
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title