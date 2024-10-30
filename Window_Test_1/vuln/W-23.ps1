###############################################

########### 23. IIS WebDAV 비활성화 ###########

$index = $checklist.check_list[22].code
$title = $checklist.check_list[22].title
$root_title = $checklist.check_list[22].root_title
$RV = "IIS 서비스 미 사용 or DisableWebDAV 값 1"
$importance = $checklist.check_list[22].importance

$flag = (Get-WindowsFeature | Where-Object { $_.Name -eq "Web-Server" } | Where-Object { $_.Installed -eq "True" }).count

if ($flag -eq 1) {
    try {
        # DisableWebDAV 경로 - HKLM:\SYSTEM\CurrentControlSet\Services\W3SVC\Parameters
        $RegPath = "HKLM:\SYSTEM\CurrentControlSet\Services\W3SVC\Parameters"
        $Name = "DisableWebDAV"

        $var = Get-ItemPropertyValue -Path $RegPath -Name $Name
    }
    catch {
        $result = "취약"
        $CV = "DisableWebDAV값 설정X"

    }
    if ($var) {
        $result = "양호"
        $CV = "DisableWebDAV값 기능 사용"

    }
    elseif ($var -eq 0) {
        # ISAPI 및 CGI 제한 설정 가져오기
        $isapiRestrictions = Get-WebConfiguration -Filter /system.webServer/security/isapiCgiRestriction

        foreach ($restriction in $isapiRestrictions.Collection) {
            $description = $restriction.Attributes["description"].Value
            $allowed = $restriction.Attributes["allowed"].Value

            if ($allowed -eq $true) {
                $result = "취약"
                $CV = "WebDAV 제한 미설정"
            }
            else {
                $result = "양호"
                $CV = "WebDAV 제한 설정"
            }
        }
    }
}
else {
    $result = "양호"
    $CV = "IIS 서비스 미사용"
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title