###############################################

########### 9. 불필요한 서비스 제거 ###########

$index = $checklist.check_list[8].code
$title = $checklist.check_list[8].title
$root_title = $checklist.check_list[8].root_title
$importance = $checklist.check_list[8].importance

# 일반적으로 불필요한 서비스 목록 (KISA 문서 참고)
$Needless_Services = @("Alerter", "Automatic Updates", "Clipbook", "Computer Browser", "Cryptographic Services", "DHCP Client",
    "Distributed Link Tracking", "DNS Client", "Error reporting Service", "Human Interface Device Access", "IMAPU CD-Buming COM Service",
    "Messenger", "NetMeeting Remote Desktop Sharing", "Portable Media Serial Number", "Print Spooler", "Remote Registry", "Simple TCP/IP Services",
    "Wireless Zero Configuration")

# 각 서비스에 대해
foreach ($serviceName in $Needless_Services) {
    # 서비스 상태 확인
    $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    
    if ($service -and $service.Status -eq 'Running') {
        try {
            # 서비스 중지
            Stop-Service -Name $serviceName -Force -ErrorAction Stop
            Write-Host "서비스 '$serviceName'가 중지되었습니다."
        } catch {
            Write-Host "서비스 '$serviceName' 중지 중 오류 발생: $($_.Exception.Message)"
        }
    }
}

$CV = "불필요한 서비스 모두 중지되었습니다."
$result = "양호"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title