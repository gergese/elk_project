###############################################

########### 18. IIS DB 연결 취약점 점검 ###########

$index = $checklist.check_list[17].code
$title = $checklist.check_list[17].title
$root_title = $checklist.check_list[17].root_title
$importance = $checklist.check_list[17].importance

$Site_List = Get-ChildItem IIS:\Sites | select -expand Name
$PSPath = 'MACHINE/WEBROOT/APPHOST'
$Filter = 'system.webServer/security/requestFiltering/fileExtensions'
$Extensions = @(".asa", ".asax")

foreach ($Location in $Site_List) {
    foreach ($ext in $Extensions) {
        # 특정 확장자 요청 필터링 설정 확인
        $existing = Get-WebConfigurationProperty -PSPath $PSPath$Location -Filter $Filter -Name "Collection" | Where-Object { $_.FileExtension -eq $ext }

        if ($existing) {
            # 이미 설정된 경우, 필터링 허용을 false로 변경
            Set-WebConfigurationProperty -PSPath $PSPath -Location $Location -Filter "$Filter/add[@fileExtension='$ext']" -Name "allowed" -Value "false"
            Write-Host "$ext 확장자에 대한 요청 필터링이 비활성화되었습니다: $Location"
        }
        else {
            # 설정이 없는 경우 추가
            Add-WebConfigurationProperty -PSPath $PSPath -Location $Location -Filter $Filter -Name "Collection" -Value @{fileExtension = $ext; allowed = "false" }
            Write-Host "$ext 확장자에 대한 요청 필터링이 추가되었습니다: $Location"
        }
    }
}

$CV = ".asa, .asax에 대한 필터링 설정"
$result = "양호"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title