###############################################

########### 23. IIS WebDAV 비활성화 ###########

$index = $checklist.check_list[22].code
$title = $checklist.check_list[22].title
$root_title = $checklist.check_list[22].root_title
$importance = $checklist.check_list[22].importance

# 레지스트리 경로 및 이름 정의
$RegPath = "HKLM:\SYSTEM\CurrentControlSet\Services\W3SVC\Parameters"
$Name = "DisableWebDAV"

# 레지스트리 키가 존재하는지 확인
if (-not (Test-Path $RegPath)) {
    # 경로가 없으면 경로를 만듭니다.
    New-Item -Path $RegPath -Force
}

# DisableWebDAV 값을 설정하거나 생성
Set-ItemProperty -Path $RegPath -Name $Name -Value 1 -Type DWord

# ISAPI 및 CGI 제한 설정 가져오기
$isapiRestrictions = Get-WebConfiguration -Filter /system.webServer/security/isapiCgiRestriction

# 각 제한에 대해 반복
foreach ($restriction in $isapiRestrictions.Collection) {
    $allowed = $restriction.Attributes["allowed"].Value

    # 현재 설정 상태 확인
    if ($allowed -eq $true) {
        # WebDAV 제한을 비활성화
        Set-WebConfigurationProperty -Filter /system.webServer/security/isapiCgiRestriction -Name "allowed" -Value "False" -PSPath $isapiRestrictions.PSPath -Location $restriction.Attributes["location"].Value
    }
}

$CV = "WebDAV 제한 설정"
$result = "양호"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title