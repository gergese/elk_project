###############################################

########### 74. 세션 연결을 중단하기 전에 필요한 유휴시간 ###########

$index = $checklist.check_list[73].code
$title = $checklist.check_list[73].title
$root_title = $checklist.check_list[73].root_title

$tempSTR = @(0, 0)

$RV = "'로그온 시간이 만료되면 클라이언트 연결 끊기 정책' 사용 & '세션 연결을 중단하기 전에 필요한 유휴시간 15분' 설정"
$importance = $checklist.check_list[73].importance

$flag_active = (Get-RegistryValue "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" | Where-Object { $_.Name -eq "enableforcedlogoff" }).Value
$flag_time = (Get-RegistryValue "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" | Where-Object { $_.Name -eq "autodisconnect" }).Value

if ($flag_active) {
    $result = "양호"
    $tempSTR[0] = "'로그온 시간이 만료되면 클라이언트 연결 끊기' 정책을 사용 중 입니다."
}
else {
    $result = "취약"
    $tempSTR[0] = "'로그온 시간이 만료되면 클라이언트 연결 끊기' 정책을 사용하고 있지 않습니다."
}

if ($flag_time -le 15) {
    $tempSTR[1] = $flag_time
}
else {
    $result = "취약"
    $tempSTR[1] = $flag_time.toString()
}

$CV = $tempSTR[0] + "유휴 시간이 " + $tempSTR[1] + "분으로 설정되어 있습니다." 

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title