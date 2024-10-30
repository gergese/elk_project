###############################################

########### 64. HTTP/FTP/SNMP 배너 차단 ###########

$index = $checklist.check_list[63].code
$title = $checklist.check_list[63].title
$root_title = $checklist.check_list[63].root_title
$importance = $checklist.check_list[63].importance

# 레지스트리 경로 설정
$RegPath = "HKLM\SYSTEM\CurrentControlSet\Services\HTTP"
$ValueName = "DisableServerHeader"

# 레지스트리 값 가져오기
$existingValue = Get-ItemProperty -Path $RegPath -Name $ValueName -ErrorAction SilentlyContinue

if ($existingValue) {
    # 값이 존재하면 1로 설정
    if ($existingValue.$ValueName -ne 1) {
        Set-ItemProperty -Path $RegPath -Name $ValueName -Value 1
    }
}
else {
    # 값이 없으면 새로 추가
    New-ItemProperty -Path $RegPath -Name $ValueName -Value 1 -PropertyType DWord
}

#FTP banner setting Read

# FTP 서비스가 설치되어 있는지 확인
if (-not (Get-WindowsFeature -Name Web-Ftp-Server).Installed) {
    Write-Host "FTP 서비스가 설치되어 있지 않습니다."
    exit
}

# 각 FTP 사이트에 대해 배너 정보 숨기기 설정
foreach ($site in $FTP_Site_List) {
    $ftpSitePath = "IIS:\Sites\$($site.Name)"

    # FTP 배너 비활성화
    Set-WebConfigurationProperty -Filter "/system.ftpServer/security/ftpRequestLogging" -PSPath $ftpSitePath -Name "logInactivity" -Value $false
    Set-WebConfigurationProperty -Filter "/system.ftpServer/security/ftpRequestLogging" -PSPath $ftpSitePath -Name "logPath" -Value "$null"
}

$CV = "모든 사이트의 배너 정보 숨김"
$result = "양호"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title