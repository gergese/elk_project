###############################################

###### 6. 관리자 그룹에 최소한의 사용자 포함 ######

$index = $checklist.check_list[5].code
$title = $checklist.check_list[5].title
$root_title = $checklist.check_list[5].root_title
$result = "수동"
$tempStr = @()

$importance = $checklist.check_list[5].importance

foreach($item in (Get-LocalGroupMember -Name Administrators).Name)
{
    $item = $item.Split('\')
    $item = $item[-1]
    $tempStr += $item
    $tempStr += ',' 
}

if($tempSTR.count -gt 0)
{
    $tempSTR[-1] = ''
}

$CV = "불필요한 관리자 그룹 사용자 획인 필요. 관리자 그룹 사용자 : " + $tempStr

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title