###############################################

############## 19. 원격 지원을 금지하도록 정책이 설정 ##############

$index = $checklist.check_list[18].code
$title = $checklist.check_list[18].title
$root_title = $checklist.check_list[18].root_title
$importance = $checklist.check_list[18].importance

$remoteAssistanceKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance"
$remoteAssistanceValue = Get-ItemProperty -Path $remoteAssistanceKey -Name fAllowToGetHelp -ErrorAction SilentlyContinue

if ($remoteAssistanceValue -ne $null) {
    if($remoteAssistanceValue.fAllowToGetHelp -eq 0) {
        $CV = "양호"
        $result = "원격 지원 비활성화"
    }
    else {
        $CV = "취약"
        $result = "원격 지원 활성화"
    }
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title