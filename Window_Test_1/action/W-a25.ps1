###############################################

########### 25. FTP 서비스 구동 점검 ###########


$index = $checklist.check_list[24].code
$title = $checklist.check_list[24].title
$root_title = $checklist.check_list[24].root_title
$importance = $checklist.check_list[24].importance

# 구동 중인 Microsoft FTP 서비스 찾기
$ftpServices = Get-Service | Where-Object {$_.Name -like "*Microsoft FTP Service*" -and $_.Status -eq "Running"}

foreach ($service in $ftpServices) {
    try {
        # 서비스 중지
        Stop-Service -Name $service.Name -Force
    } catch {
        Write-Host "서비스 '$($service.DisplayName)' 중지 중 오류 발생: $_"
    }
}

$CV = "FTP 구동 중지"
$result = "양호"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title