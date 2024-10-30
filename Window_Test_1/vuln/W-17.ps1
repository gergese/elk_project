###############################################

########### 17. IIS 파일 업로드 및 다운로드 제한 ###########

$index = $checklist.check_list[16].code
$title = $checklist.check_list[16].title
$root_title = $checklist.check_list[16].root_title
$RV = "업로드 / 다운로드 용량을 제한"
$importance = $checklist.check_list[16].importance

$total_web_count = 0
$tempSTR = @()
$temp_count = 0

if ($IIS_Site_List -eq $null) {
    $result = "양호"
    $CV = "IIS 미설치"
}
else {
    # applicationHost.config 파일 경로
    $configPath = "%systemroot%\Windows\System32\inetsrv\config\applicationHost.config"

    # 파일이 존재하는지 확인
    if (Test-Path $configPath) {
        # XML 파일 로드
        [xml]$config = Get-Content $configPath

        # <system.webServer><asp><limits> 섹션에서 maxRequestEntityAllowed 확인
        $limits = $config.configuration.'system.webServer'.asp.limits

        if ($limits -ne $null) {
            $maxRequestEntityAllowed = $limits.maxRequestEntityAllowed

            if ($maxRequestEntityAllowed -ne $null -and $maxRequestEntityAllowed -le 200000) {
                $result = "양호"
                $CV = "maxRequestEntityAllowed 설정 : $maxRequestEntityAllowed"
            }
            elseif ($maxRequestEntityAllowed -gt 200000) {
                $result = "수동"
                $CV = "maxRequestEntityAllowed 값 확인 필요 : $maxRequestEntityAllowed"
            } 
            else {
                $result = "취약"
                $CV = "maxRequestEntityAllowed 설정이 없습니다."
            }
        }
        else {
            $result = "취약"
            $CV = "maxRequestEntityAllowed 설정이 없습니다."
        }
    }
    else {
        # IIS 설치 여부에 따라 없을 수도 있음
        $result = "취약"
        $CV = "applicationHost.config 파일이 없습니다."
    }

    for ($X = 0; $X -lt $Site_Name_list.count; $X++) {
        # web.config 파일이 존재하는지 확인
        $flag = (Get-ChildItem $Site_Path_list[$X] | Where-Object { $_.Name -eq "web.config" }).count

        # web.config 파일이 존재하지 않을 때
        if ($flag -eq 0) {
            $result = "취약"
            $total_web_count++
            $tempSTR += $Site_Name_list[$X]
            $tempSTR += ','
        }

        #web.config 파일이 정상적으로 홈 디렉토리에 1개가 존재하는 경우
        elseif ($flag -eq 1) {
            #web.config 파일 경로 얻기
            $web_config_file_path = (Get-ChildItem $Site_Path_list[$X] | Where-Object { $_.Name -eq "web.config" }).Fullname

            #다운로드/업로드 사용 여부 확인
            $downloadEnabled = Get-Content $web_config_file_path | Select-String -Pattern "enableRangeTracking"
            $uploadEnabled = Get-Content $web_config_file_path | Select-String -Pattern "allowDoubleEscaping"

            if (!$downloadEnabled -and !$uploadEnabled) {
                continue
            }
            else {
                $temp_count++
        
                #web.config 파일 내에서 파일 업로드 관련 설정이 있는지 확인
                $upload_option = Get-Content $web_config_file_path | Select-String -Pattern "maxAllowedContentLength"

                #web.config 파일 내에서 파일 다운로드 관련 설정이 있는지 확인
                $download_option = Get-Content $web_config_file_path | Select-String -Pattern "bufferingLimit"

                if ($upload_option.length -le 0 -or $download_option.length -le 0) {
                    $tempSTR += $Site_Name_list[$X]
                    $tempSTR += ','
                    $total_web_count++
                } 
            }
        }

        #web.config 파일이 비 정상적으로 많이 생성 되었을 때 
        else {
            $result = "취약"
            $total_web_count++
            $tempSTR += $Site_Name_list[$X]
            $tempSTR += ','
        }

    }

    if ($tempSTR.count -gt 0) {
        $tempSTR[-1] = ''
    }

    if ($total_web_count -gt 0) {
        $result = "취약"
        $CV = ("업로드 혹은 다운로드 설정이 되지 않은 사이트는 " + $tempSTR + " 입니다.")
    }
    elseif ($temp_count -eq 0) {
        $result = "양호"
        $CV = ("모든 사이트가 업로드 / 다운로드 미사용")
    }
    else {
        $result = "양호"
        $CV = ("모든 사이트가 업로드 / 다운로드 설정이 되어 있습니다.")
    }
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title