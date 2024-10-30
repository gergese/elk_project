###############################################

########### 61. SNMP 서비스 커뮤니티 스트링의 복잡성 설정 ###########

$index = $checklist.check_list[60].code
$title = $checklist.check_list[60].title
$root_title = $checklist.check_list[60].root_title

$RV = "SNMP 서비스 사용X / Community String 이 public 혹은 private 가 아님"
$importance = $checklist.check_list[60].importance

$flag = (Get-Service -Name *SNMP* | Where-Object {$_.Status -like "*Running*"}).count
$count = 0

$tempSTR = @()

if($flag -gt 0)
{
    $Community_Strings = Get-RegistryValue "HKLM\SYSTEM\CurrentControlSet\services\SNMP\Parameters\ValidCommunities"

    if($Community_Strings.Count -gt 0)
    {
        foreach($item in $Community_Strings)
        {
            if($item.Name -like "*public*" -or $item.Name -like "*private*")
            {
                $count++
            }
        }

        if($count -gt 0)
        {
            $result = "취약"
            $CV = "Community String 목록에 'public' 또는 'private'의 이름이 존재"
        }
        else
        {
            $result = "양호"
            $CV = "Community String 목록에 'public' 또는 'private'의 이름이 존재하지 않습니다"
        }

        foreach($item in $Community_Strings)
        {
            $tempSTR += $item
            $tempSTR += ','
        }
    }
    else
    {
        $result = "양호"
        $CV = "Community String을 사용하지 않습니다."
    }

    if($tempSTR.count -gt 0)
    {
        $tempSTR[-1] = ''
    }
}
else
{
    $result = "양호"
    $CV = "현재 서버에서 SNMP 서비스가 실행되고 있지 않습니다."
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title