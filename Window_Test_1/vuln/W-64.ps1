###############################################

########### 64. HTTP/FTP/SNMP 배너 차단 ###########

$index = $checklist.check_list[63].code
$title = $checklist.check_list[63].title
$root_title = $checklist.check_list[63].root_title

$RV = "배너 정보가 보이지 않는 경우"
$importance = $checklist.check_list[63].importance

$flag = (Get-RegistryValue "HKLM\SYSTEM\CurrentControlSet\Services\HTTP" | Where-Object {$_.Name -like "*DisableServerHeader*"}).Value

$total_web_count = 0
$tempSTR = @()

# HTTP Header Option Read
if($flag -eq 1)
{
    $result = "양호"
}
else
{
    $result = "취약"
}

#FTP banner setting Read

for($X=0;$X -lt $FTP_Site_Name_list.count;$X++)
{
    $ftp_banner_option = Get-WebConfiguration //siteDefaults//. -PSPath $FTP_Site_Path_list[$X] | select-object suppressDefaultBanner

    if($ftp_banner_option -like "*False*")
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

if($result -eq "양호")
{
    if($total_web_count -gt 0)
    {
        $result = "취약"
        $CV = "HTTP 헤더 제거 옵션이 적용되어 있으며, 배너 설정을 하지 않은 FTP 사이트는 " + $tempSTR +"입니다."
    }
    else
    {
        $CV = "HTTP 헤더 제거 옵션이 적용되어 있으며, 모든 FTP 사이트가 배너 설정이 적용 되어 있습니다."
    }
}
else
{
    if($total_web_count -gt 0)
    {
        $result = "취약"
        $CV = "HTTP 헤더 제거 옵션이 적용되어 있지 않으며, 배너 설정을 하지 않은 FTP 사이트는 " + $tempSTR +"입니다."
    }
    else
    {
        $result = "취약"
        $CV = "HTTP 헤더 제거 옵션이 적용되어 있지 않으며, 모든 FTP 사이트가 배너 설정이 적용 되어 있습니다."
    }
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title