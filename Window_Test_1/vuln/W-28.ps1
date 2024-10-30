###############################################

########### 28. FTP 접근 제어 설정 ###########


$index = $checklist.check_list[27].code
$title = $checklist.check_list[27].title
$root_title = $checklist.check_list[27].root_title
$importance = $checklist.check_list[27].importance
$total_web_count = 0

$tempSTR = @()

# FTP 사이트가 존재할 경우
if($FTP_Site_List.length -ne 0)
{
    for($X=0;$X -lt $FTP_Site_Name_list.count;$X++)
    {
        $Web_Property_Filter = "/system.ftpserver/security/ipsecurity"

        $Everyone_Access = Get-WebConfigurationProperty -Filter $Web_Property_Filter -name allowUnlisted  -PSPath $FTP_Site_Path_list[$X] | Select-Object "Value"

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
        $CV = ("접근 제어를 설정하지 않은 FTP 사이트는 " + $tempSTR + " 입니다.")
    }
    else
    {
        $result = "양호"
        $CV = ("접근 제어를 설정하지 않은 FTP 사이트는 없습니다.")
    }
}
# FTP 사이트가 존재하지 않을 경우
else
{
    $result = "양호"
    $CV = "FTP 사이트를 사용하지 않습니다."
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title