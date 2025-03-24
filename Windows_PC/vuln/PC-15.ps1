###############################################

######### 15. 복구 콘솔에서 자동 로그온을 금지하도록 설정 #########

$index = $checklist.check_list[14].code
$title = $checklist.check_list[14].title
$root_title = $checklist.check_list[14].root_title
$importance = $checklist.check_list[14].importance

$securityLevel = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Setup\RecoveryConsole" -Name SecurityLevel -ErrorAction SilentlyContinue
if($securityLevel -ne $null) {
    if($securityLevel.SecurityLevel -eq 1) {
        $CV = "양호"
        $result =  "복구 콘솔 자동 로그인 허용이 사용으로 설정"
    }
    elseif($securityLevel.SecurityLevel -eq 0) {
        $CV = "취약"
        $result = "복구 콘솔 자동 로그인 허용이 사용 안 함으로 설정"
    }
}
else {
    $CV = "취약"
    $result = "복구 콘솔 자동 로그인 설정을 확인할 수 없음"
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title