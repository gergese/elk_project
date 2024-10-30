###############################################

########### 17. IIS 파일 업로드 및 다운로드 제한 ###########

$index = $checklist.check_list[16].code
$title = $checklist.check_list[16].title
$root_title = $checklist.check_list[16].root_title
$importance = $checklist.check_list[16].importance

for($X=0;$X -lt $Site_Name_list.count;$X++)
{
    # 웹사이트의 web.config 파일 경로를 얻기
    $web_config_file_path = (Get-ChildItem $Site_Path_list[$X] | Where-Object {$_.Name -eq "web.config"}).Fullname

    if ($web_config_file_path) {
        # web.config 파일 내에서 파일 업로드 관련 설정 확인
        $upload_option = Get-Content $web_config_file_path | Select-String -Pattern "maxAllowedContentLength"

        # 업로드 설정이 있으면 값 변경, 없으면 추가
        if ($upload_option) {
            # 기존 설정 수정
            (Get-Content $web_config_file_path) -replace 'maxAllowedContentLength\s*=\s*"\d+"', 'maxAllowedContentLength="31457280"' | Set-Content $web_config_file_path
        } else {
            # 설정이 없으면 추가 (예: <requestLimits> 태그에 추가해야 함)
            Add-Content -Path $web_config_file_path -Value '<requestLimits maxAllowedContentLength="31457280" />'
        }

        # web.config 파일 내에서 파일 다운로드 관련 설정 확인
        $download_option = Get-Content $web_config_file_path | Select-String -Pattern "bufferingLimit"

        # 다운로드 설정이 있으면 값 변경, 없으면 추가
        if ($download_option) {
            # 기존 설정 수정
            (Get-Content $web_config_file_path) -replace 'bufferingLimit\s*=\s*"\d+"', 'bufferingLimit="4194304"' | Set-Content $web_config_file_path
        } else {
            # 설정이 없으면 추가 (적절한 태그 안에 추가 필요)
            Add-Content -Path $web_config_file_path -Value '<system.webServer><httpProtocol><bufferingLimit value="4194304" /></httpProtocol></system.webServer>'
        }
    } else {
        Write-Host "web.config 파일을 찾을 수 없습니다: $Site_Path_list[$X]"
    }
}

$CV = "업로드/다운로드 제한 설정"
$result = "양호"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title