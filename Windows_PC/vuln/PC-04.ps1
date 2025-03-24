###############################################

########### 4. 불필요한 서비스 제거 ###########

$index = $checklist.check_list[3].code
$title = $checklist.check_list[3].title
$root_title = $checklist.check_list[3].root_title
$importance = $checklist.check_list[3].importance

# 일반적으로 불필요한 서비스 목록 (KISA 문서 참고)
$Needless_Services = @("Alerter", "Automatic Updates", "Clipbook", "Computer Browser", "Cryptographic Services", "DHCP Client",
    "Distributed Link Tracking", "DNS Client", "Error reporting Service", "Human Interface Device Access", "IMAPU CD-Buming COM Service",
    "Messenger", "NetMeeting Remote Desktop Sharing", "Portable Media Serial Number", "Print Spooler", "Remote Registry", "Simple TCP/IP Services",
    "Wireless Zero Configuration")

$count = 0
$tempSTR = @()
 
foreach ($item in $Needless_Services) {   
    $var = @(Get-Service | Where-Object { $_.Status -eq 'Running' } | Where-Object { $_.DisplayName -like $item } | Format-List)
    if ($var.length -gt 0) {
        $tempSTR += $item
        $tempSTR += ','

        $count++
    }
}
if ($tempSTR.count -gt 0) {
    $tempSTR[-1] = ''
}

if ($count -gt 0) {
    $result = "취약"
    $CV = "구동중인 불필요한 서비스의 목록은 " + $tempSTR
}
else {
    $result = "양호"
    $CV = "구동중인 불필요한 서비스가 존재하지 않습니다."
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title