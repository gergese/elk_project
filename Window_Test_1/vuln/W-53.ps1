###############################################

############# 53. 로컬 로그온 허용 ############

$index = $checklist.check_list[52].code
$title = $checklist.check_list[52].title
$root_title = $checklist.check_list[52].root_title
$RV = "Administrator, IUSR_ 만 존재"
$importance = $checklist.check_list[52].importance
$CV = @()

$String_1 = Get-content ./user_rights.inf | Select-String "SeInteractiveLogonRight"
$String_1 = Out-String -InputObject $String_1

$String_1 = $String_1 -replace "`\s+",''

$String_2 = $String_1.Split("*,")
$SID_List = @()
$count = 0

for($X=1;$X -lt $String_2.count;$X++)
{
    if($String_2[$X].length -ne 0)
    {
        $SID_List += $String_2[$X]
    }
}

foreach($SID_ITEM in $SID_List)
{
    $flag = Convert_SID_TO_USERNAME $SID_ITEM

    $flag = Out-String -InputObject $flag
    $flag = $flag.Split('\')
    $flag = $flag[-1].Trim()

    $CV += $flag
    $CV += ','

    if(!($flag -like "*Administrator*" -or $flag -like "*IUSR*"))
    {
        $count++
    }
}

$CV[-1] = ''

if($count -eq 0)
{
    $result = "양호"
}
else
{
    $result = "취약"
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title