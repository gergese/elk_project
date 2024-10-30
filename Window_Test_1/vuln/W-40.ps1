###############################################

########### 40. 원격 시스템에서 강제로 시스템 종료 ###########

$index = $checklist.check_list[39].code
$title = $checklist.check_list[39].title
$root_title = $checklist.check_list[39].root_title

$RV = "해당 정책에 'Administrator'만 존재하는 경우"
$importance = $checklist.check_list[39].importance

$tempSTR = @()

$String_1 = Get-Content -Path ./user_rights.inf | select-string -Pattern "SeRemoteShutdownPrivilege"
$String_1 = Out-String -InputObject $String_1

$String_1 = $String_1 -replace "`\s+", ''

$String_2 = $String_1.Split("*,")
$SID_List = @()
$count = 0
for ($X = 1; $X -lt $String_2.count; $X++) {
    if ($String_2[$X].length -ne 0) {
        $SID_List += $String_2[$X]
    }
}

foreach ($SID_ITEM in $SID_List) {
    $flag = Convert_SID_TO_USERNAME $SID_ITEM

    $tempSTR += $flag
    $tempSTR += ','

    if (!($flag -like "*Administrator*")) {
        $count++
    }
}

if ($tempSTR.count -gt 0) {
    $tempSTR[-1] = ''
}


if ($count -eq 0) {
    $result = "양호"
    $CV = "원격 시스템에서 강제로 시스템 종료 가능 정책에 Administrator 계정만 포함되어 있습니다."
}
else {
    $result = "취약"
    $CV = $tempSTR + " 계정들이 원격 시스템에서 강제로 시스템 종료 가능 정책에 포함되어 있습니다."
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title