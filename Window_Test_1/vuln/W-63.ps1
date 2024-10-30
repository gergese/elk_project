###############################################

########### 63. DNS 서비스 구동 점검 ###########

$index = $checklist.check_list[62].code
$title = $checklist.check_list[62].title
$root_title = $checklist.check_list[62].root_title

$RV = "DNS 서비스를 사용하지 않거나 동적 업데이트를 사용하지 않음"
$importance = $checklist.check_list[62].importance

if((Get-Service *DNS*).count -gt 0)
{
    try {
        $flag = (Get-DnsServer).dynamicupdate

        if($flag.length -eq 0)
        {
            $result = "양호"
            $CV = "DNS 서버의 동적 업데이트 옵션이 비활성화 되어 있습니다."
        }
        else
        {
            $result = "취약"
            $CV = "DNS 서버의 동적 업데이트 옵션이 활성화 되어 있습니다."
        }
    }
    catch {
        $CV = "DNS 관련 서비스를 사용하고 있지 않습니다."
        $result = "양호"
    }
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title