###############################################

########### 66. 불필요한 ODBC / OLE-DB 데이터 소스와 드라이브 제거 ###########

$index = $checklist.check_list[65].code
$title = $checklist.check_list[65].title
$root_title = $checklist.check_list[65].root_title

$RV = "시스템 DSN 부분의 Data Source를 현재 사용하는 경우"
$importance = $checklist.check_list[65].importance
$tempSTR = @()

$odbc_list = (Get-OdbcDsn).Name

if($odbc_list.count -gt 0)
{
    $result = "취약"

    foreach($item in $odbc_list)
    {
        $tempSTR += $item
        $tempSTR += ','
    }

    if($tempSTR.count -gt 0)
    {
        $tempSTR[-1] = ''
    }

    $CV = "현재 사용중인 ODBC는 " + $tempSTR + " 입니다."
}
else
{
    $result = "양호"
    $CV = "해당 서버에서 ODBC를 사용하고 있지 않습니다."
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title