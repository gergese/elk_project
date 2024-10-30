###############################################

########### 72. DoS 공격 방어 레지스트리 설정 ###########

$index = $checklist.check_list[71].code
$title = $checklist.check_list[71].title
$root_title = $checklist.check_list[71].root_title

$RV = "DoS 방어 레지스트리 값을 적절하게 설정"
$importance = $checklist.check_list[71].importance

$tempSTR = @(0, 0, 0, 0)
$CV = ""

$Reg_Path = "HKLM\System\CurrentControl\Set\Services\Tcpip\Parameters\"

$flag = Test-RegistryValue $RegPath "SynAttackProtect"
if ($flag) {
    $SynAP_Value = (Get-RegistryValue $RegPath | Where-Object { $_.Name -eq "SynAttackProtect" }).Value
}

$flag = Test-RegistryValue $RegPath "EnableDeadGWDetect"
if ($flag) {
    $EnableDGWD_Value = (Get-RegistryValue $RegPath | Where-Object { $_.Name -eq "EnableDeadGWDetect" }).Value
}

$flag = Test-RegistryValue $RegPath "KeepAliveTime"
if ($flag) {
    $KeepAT_Vaule = (Get-RegistryValue $RegPath | Where-Object { $_.Name -eq "KeepAliveTime" }).Value
}

$flag = Test-RegistryValue $RegPath "NoNameReleaseOnDemand"
if ($flag) {
    $NoNameROD_Value = (Get-RegistryValue $RegPath | Where-Object { $_.Name -eq "NoNameReleaseOnDemand" }).Value
}

############

if ($SynAP_Value -eq $null -or $SynAP_Value -eq 0) {
    $result = "취약"
    $tempSTR[0] = "현재 SynAttack 프로텍션을 사용하지 않습니다."
}
else {
    if ($SynAP_Value -eq 1) {
        $tempSTR[0] = "현재 SynAttackProtect 값은 1이며, 재전송 시간 감소 / route 캐쉬 엔트리를 지연시키는 방어 기능이 적용된 상태이다."
    }
    elseif ($SynAP_Value -eq 2) {
        $tempSTR[0] = "현재 SynAttackProtect 값은 2이며, 재전송 시간 감소 / route 캐쉬 엔트리를 지연 / Winsock에 대한 지시를 지연시키는 방어 기능이 적용된 상태이다."
    }
}

if ($EnableDGWD_Value -eq $null) {
    $result = "취약"
    $tempSTR[1] = "현재 EnableDeadGWDetect 값을 설정하지 않았습니다."
}
else {
    if ($EnableDGWD_Value -eq 0) {
        $tempSTR[1] = "현재 EnableDeadGWDetect 값은 0이며, 작동하지 않는 Gateway를 검색할 수 있는 상태이다."
    }
    else {
        $result = "취약"
        $tempSTR[1] = "현재 EnableDeadGWDetect 값은 1이며, 작동하지 않는 Gateway를 검색할 수 없는 상태이다."
    }
}

if ($KeepAT_Vaule -eq $null) {
    $result = "취약"
    $tempSTR[2] = "현재 KeepAliveTime 값을 설정하지 않았습니다."
}
else {
    if ($KeepAT_Vaule -eq 300000) {
        $tempSTR[2] = "현재 KeepAliveTime 값은 300000(5분)이며, 5분에 한번씩 Keep-alive 패킷을 전송합니다."
    }
    else {
        $result = "취약"
        $tempSTR[2] = "현재 KeepAliveTime 값은 " + $KeepAT_Vaule.toString() + " 이며, " + ($KeepAT_Vaule / 6000).toString() + "분에 한번씩 Keep-alive 패킷을 전송합니다."
    }
}

if ($NoNameROD_Value -eq $null) {
    $result = "취약"
    $tempSTR[3] = "현재 NoNameReleaseOnDemand 값을 설정하지 않았습니다."
}
else {
    if ($NoNameROD_Value -eq 1) {
        $tempSTR[3] = "현재 NoNameReleaseOnDemand 기능을 사용하는 중입니다."
    }
    else {
        $result = "취약"
        $tempSTR[3] = "현재 NoNameReleaseOnDemand 기능을 사용하지 않습니다."
    }
}

foreach ($item in $tempSTR) {
    $CV += $item
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title