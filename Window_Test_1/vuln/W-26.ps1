########### 26. FTP 디렉토리 접근권한 설정 ###########

$index = $checklist.check_list[25].code
$title = $checklist.check_list[25].title
$root_title = $checklist.check_list[25].root_title
$RV = "FTP 홈 디렉토리에 Everyone 권한이 없는 경우"
$importance = $checklist.check_list[25].importance

$total_web_count = 0

$tempSTR = @()

if($FTP_Site_List.length -ne 0)
{
    for($X=0;$X -lt $FTP_Site_Name_list.count;$X++)
    {
            $Everyone_Access = (Get-Permissions -Path $FTP_Site_Path_Full_Path_list[$X] | Where-Object {$_.IdentityReference -like "*Everyone*"}).Count
        
            if($Everyone_Access -eq 0)
            {
                #echo($FTP_Site_Name_list[$X] + " 사이트 홈 디렉토리에 Everyone 권한이 존재하지 않습니다. - 양호")
            }
            else
            {                
                $total_web_count++
                $tempSTR += $FTP_Site_List[$X]
                $tempSTR += ','

                #echo($FTP_Site_Name_list[$X] + " 사이트 홈 디렉토리에 Everyone 권한이 존재합니다. - 취약")
            }
    }

    if($tempSTR.count -gt 0)
    {
        $tempSTR[-1] = ''
    }

    if($total_web_count -gt 0)
    {
        $result = "취약"
        $CV = ("홈 디렉토리에 Everyone 권한이 존재하는 FTP 사이트는 "+ $tempSTR +"입니다.")
    }
    else
    {
        $result = "양호"
        $CV = ("홈 디렉토리에 Everyone 권한이 존재하는 FTP 사이트는 없습니다.")
    }
}
else
{
    $result = "양호"
    $CV = "FTP 사이트를 사용하지 않습니다."
    #echo("FTP 사이트를 사용하지 않습니다. - 양호")
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title