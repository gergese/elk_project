###############################################

########### 19. IIS 가상 디렉토리 삭제 ###########

$index = $checklist.check_list[18].code
$title = $checklist.check_list[18].title
$root_title = $checklist.check_list[18].root_title
$RV = "IIS Admin, IIS Adminpwd 가상 디렉토리 존재X"
$importance = $checklist.check_list[18].importance

$total_web_count = 0

$tempSTR = @()

# IIS 6.0 이상
if($IIS_version -ge 6)
{
    $CV = "IIS 6.0 버전 이상은 해당X"
    $result = "양호"
}

# IIS 6.0 미만
elseif($IIS_version -lt 6)
{
    for($X=0;$X -lt $Site_Name_list.count;$X++)
    {
        $flag_admin = (Get-ChildItem $Site_Path_list[$X] | Where-Object {$_.Name -eq "IIS Admin"}).count
        if($flag_admin -gt 0)
        {
            #echo($Site_Name_list[$X] + "사이트에 IIS Admin 가상 디렉토리가 존재합니다. - 취약")
        }

        $flag_adpwd = (Get-ChildItem $Site_Path_list[$X] | Where-Object {$_.Name -eq "IIS Adminpwd"}).count
        if($flag_adpwd -gt 0)
        {
            #echo($Site_Name_list[$X] + "사이트에 IIS Adminpwd 가상 디렉토리가 존재합니다. - 취약")
        }

        if($flag_admin -eq 0 -and $flag_adpwd -eq 0)
        {
            #echo($Site_Name_list[$X] + "사이트에는 IIS Admin, IIS Adminpwd 가상 디렉토리가 존재하지 않습니다. - 양호")
        }
        else 
        {
            $tempSTR += $Site_Name_list[$X]
            $tempSTR += ','

            $total_web_count++   
        }

    }

    if($tempSTR.count -gt 0)
    {
        $tempSTR[-1] = ''
    }


    if($total_web_count -gt 0)
    {
        $CV = ($tempSTR + " 사이트에서 가상 디렉토리 발견")
        $result = "취약"
    }
    else
    {
        $CV = ("모든 사이트에서 가상 디렉토리 미발견")
        $result = "양호"
    }
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title