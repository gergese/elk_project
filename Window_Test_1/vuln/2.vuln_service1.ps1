# 문서화를 위한 결과 저장 변수
$index = 0
$root_title = "서비스 관리"
$title = 0
$result = 0

#################################################### < 2 . 서비스 관리 > ####################################################
#############################################################################################################################

#############################################################################################################

###### 7. 공유 권한 및 사용자 그룹 설정 ######

$index = "07"
$title = "공유 권한 및 사용자 그룹 설정"
$result_act = $false
$RV = "일반 공유 디렉토리 X / 접근 권한에 Everyone 권한이 없음"
$importance = "상"

# 모든 공유 폴더 중 Everyone으로 공유 된 폴더 정보를 조회
$SmbShareInfo = @(Get-SmbShare | foreach { Get-SmbShareAccess -Name $_.Name } | Where-Object { $_.AccountName -like 'Everyone' })
$var = $SmbShareInfo.Length
$CV = @()

$temp = $SmbShareInfo.Name

if ($var -gt 0) {
    $result = "취약"
    foreach ($item in $temp) {
        $CV += ($item + ',')
    }
    $CV[-1] = "공유 폴더가 Everyone 권한으로 공유 중"

}
else {
    $result = "양호"
    $CV = "Everyone 권한이 있는 공유 폴더 존재X"
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

###### 8. 하드디스크 기본 공유 제거 ######

$index = "08"
$title = "하드디스크 기본 공유 제거"
$result_act = $false
$RV = "AutoShareServer 값이 0 & 기본 공유가 존재X"
$importance = "상"

# IPC$를 제외한 기본 공유 폴더가 존재하는지 확인
$DefaultSmbInfo = @(Get-SmbShare | Where-Object { $_.Name -ne "IPC$" } | Where-Object { $_.Name -like "*$" })
$var = $DefaultSmbInfo.Length
$result_act = $false
$RegPath = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters"
$Name = "AutoShareServer"

try {
    $REGvar = Get-ItemPropertyValue -Path $RegPath -Name $Name
}
catch {
}

if ($var -gt 0) {
    $result = "취약"
    $CV = "기본 공유 폴더가 존재하며, "
}
else {
    $result = "양호"
    $CV = "기본 공유 폴더가 존재하지 않으며, "
}

if ($REGvar -eq 0) {
    $CV += "AutoShareServer 값은 0"
}
elseif ($REGvar -eq 1) {
    $result = "취약"
    $CV += "AutoShareServer 값은 1"
}
else {
    $result = "취약"
    $CV += "AutoShareServer 값 설정X"
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

########### 9. 불필요한 서비스 제거 ###########

$index = "09"
$title = "불필요한 서비스 제거"
$result_act = $false
$RV = "일반적으로 불필요한 서비스들을 중지"
$importance = "상"

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

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

########### 10 .IIS 서비스 구동 점검 ##########

$index = "10"
$title = "IIS 서비스 구동 점검"
$result = "수동"
$result_act = $false
$RV = "IIS 서비스를 사용하지 않는 경우엔 중지"
$importance = "상"
$CV = "IIS 서비스 사용 여부 확인 필요"
# $IIS_Services = @("IISADMIN","FTPSVC","W3SVC","WAS")

# $count = 0

# $tempSTR = @()


# foreach($item in $IIS_Services)
# {
#     $var = Get-Service | Where-Object {$_.Status -eq 'Running'} | Where-Object {$_.Name -like $item} | Format-List
#     if($var.length -gt 0)
#     {
#         $tempSTR += $item
#         $tempSTR += ','

#         $count++
#     }
# }

# if($tempSTR.count -gt 0)
# {
#     $tempSTR[-1] = ''
# }

# if($count -gt 0)
# {
#     $result = "취약"
#     $CV = ("구동중인 IIS 서비스는 " + $tempSTR)
# }
# else
# {
#     $result = "양호"
#     $CV = ("구동중인 IIS 서비스는 없습니다.")
# }

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

########### 11. 디렉토리 리스팅 제거 ###########

$index = "11"
$title = "디렉토리 리스팅 제거"
$result_act = $false
$RV = " 디렉토리 검색 옵션 해제"
$importance = "상"

$count = 0 

$tempSTR = @()

# IIS가 구동 중인지 확인
if ((Get-Service -Name 'W3SVC').Status -eq 'Running') {
    $Site_List = Get-ChildItem IIS:\Sites | select -expand Name

    $PSPath = 'MACHINE/WEBROOT/APPHOST'
    $Filter = 'system.webServer/directoryBrowse'
    $Name = 'enabled'
    
    foreach ($Location in $Site_List) {
        # 디렉토리 검색 허용 / 차단 설정한 값을 확인한다.
        $var = (Get-WebConfigurationProperty -PSPath $PSPath -Location $Location -Filter $Filter -Name $Name).Value
    
        if ($var) {
            $tempSTR += $Location
            $tempSTR += ','
    
            $count++
        }
    }
    
    if ($tempSTR.count -gt 0) {
        $tempSTR[-1] = ''
    }
    
    if ($count -eq 0) {   
        $result = "양호"
        $CV = ("모든 사이트에서 디렉토리 검색 차단")
    }
    else {
        $result = "취약"
        $CV = ($tempSTR + "사이트에서 디렉토리 검색 허용")    
    }
}
else {
    $result = "양호"
    $CV = ("IIS 서비스 미사용")
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

######### 12. IIS CGI 실행 제한 양호 #########

$index = "12"
$title = "IIS CGI 실행 제한 양호"
$result_act = $false
$RV = "Everyone에 권한이 없는 경우"
$importance = "상"

# IIS가 구동 중인지 확인
if ((Get-Service -Name 'W3SVC').Status -eq 'Running') {
    $var = Test-Path -Path "C:\inetpub\scripts"
    if (!$var) {
        $result = "양호"
        $CV = "CGI 디렉토리 존재 X"
    }
    else {
        $access_info = Get-SmbShare | Where-Object { $_.Name -eq "script" } | Where-Object { $_.AccountName -like 'Everyone' }
    
        if ($access_info.length -gt 0) {
            $result = "취약"
            $CV = "Everyone 권한이 존재"
        }
        else {
            $result = "양호"
            $CV = "Everyone 권한이 존재하지 않음"
            $access_info = Get-SmbShareAccess | Where-Object { $_.Name -eq "script" } | Format-wide
        }
    }    
}
else {
    $result = "양호"
    $CV = "IIS 서비스 미사용"
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

########### 13. IIS 상위 디렉토리 접근 금지 ###########

$index = "13"
$title = "IIS 상위 디렉토리 접근 금지"
$result_act = $false
$RV = "상위 패스 기능 제거"
$importance = "상"
$Site_List = Get-ChildItem IIS:\Sites | select -expand Name
$count = 0 

$tempSTR = @()

$PSPath = 'MACHINE/WEBROOT/APPHOST'
$Filter = 'system.webServer/asp'
$Name = 'enableParentPaths'

foreach ($Location in $Site_List) {
    # 부모 디렉토리 접근 허용 / 차단 설정한 값을 확인한다.
    $var = Get-WebConfigurationProperty -PSPath $PSPath -Location $Location -Filter $Filter -Name $Name | Select-Object -ExpandProperty Value
    
    if ($var -eq $true) {
        $count++

        $tempSTR += $Location
        $tempSTR += ','

    }
}

if ($tempSTR.count -gt 0) {
    $tempSTR[-1] = ''
}

if ($count -eq 0) {
    $result = "양호"
    $CV = "모든 사이트가 상위 디렉토리 접근 금지가 적용"
}
else {
    $result = "취약"
    $CV = ($tempSTR + " 사이트가 상위 디렉토리 접근 적용")
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

########### 14. IIS 불필요한 파일 제거 ##########

# 진단 대상 Windows 2000, 2003이라 제외

# IIS 7.0 (Windows 2008) 이상 버전 해당 없음

$index = "14"
$title = "IIS 불필요한 파일 제거"
$result_act = $false
$RV = "IISSamples, IIS Help 가상 디렉토리 제거"
$importance = "상"

if ($IIS_version -lt 7) {
    $CV = "수동 확인 후 존재 시 삭제"
    $result = "수동"
}
if ($IIS_version -ge 7) {
    $CV = "양호"
    $result = "대상X"
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

########### 15. 웹 프로세스 권한 제한 ###########

$index = "15"
$title = "웹 프로세스 권한 제한"
$result = "수동"
$result_act = $false
$RV = "웹 서비스 운영에 필요한 최소 권한으로 설정"
$importance = "상"

# 애플리케이션 풀 아이덴티티와 ID를 가져오는 함수 정의
function Get-AppPoolDetails {
    param (
        [string]$Site_Name
    )

    # 애플리케이션 풀 이름 가져오기
    $AppPoolName = Get-WebConfigurationProperty -PSPath "MACHINE/WEBROOT/APPHOST" -Filter "system.applicationHost/sites/site[@name='$Site_Name']/application[@path='/']" -Name "applicationPool" | Select-Object -ExpandProperty Value

    # 애플리케이션 풀 정보 가져오기 (Get-IISAppPool 사용)
    $AppPool = Get-IISAppPool | Where-Object { $_.Name -eq $AppPoolName }

    if ($AppPool) {
        $AppPoolIdentity = $AppPool.processModel.identityType
        $AppPoolID = $AppPool.id

        return @{
            Identity = $AppPoolIdentity
            ID       = $AppPoolID
        }
    }
    else {
        Write-Host "Application Pool '$AppPoolName' not found."
        return $null
    }
}

# 애플리케이션 풀 아이덴티티와 ID를 가져와서 출력
foreach ($Site_Name in $Site_Name_list) {
    $AppPoolDetails = Get-AppPoolDetails -Site_Name $Site_Name
    if ($AppPoolDetails.Identity -ne "ApplicationPoolIdentity") {
        $result = "취약"
        $CV = "ApplicationPoolIdentity가 적용되지 않은 사이트 존재"
    }
    else {
        $CV = "웹 서비스 운영에 필요한 최소 권한 확인 필요"
    }
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

########### 16. IIS 링크 사용 금지 ###########


$index = "16"
$title = "IIS 링크 사용 금지"
$importance = "상"
$result_act = $false
$RV = "바로가기(.lnk) 파일의 사용 허용X"

$total_web_count = 0
$total_lnk_count = 0
$tempSTR = @()

for ($X = 0; $X -lt $Site_Name_list.count; $X++) {
    $lnk_count = (Get-ChildItem $Site_Path_list[$X] -Recurse | Where-Object { $_.Name -like "*.lnk" }).count

    if ($lnk_count -gt 0) {
        $total_web_count++
        $total_lnk_count += $lnk_count

        $tempSTR += $Site_Name_list[$X]
        $tempSTR += ','
    }

}

if ($tempSTR.count -gt 0) {
    $tempSTR[-1] = ''
}

if ($total_web_count -gt 0) {
    $result = "취약"
    $CV = ("lnk파일 존재 사이트는 " + $tempSTR + " 입니다.")
}
else {
    $result = "양호"
    $CV = "모든 사이트에 lnk 파일이 존재하지 않습니다."
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

########### 17. IIS 파일 업로드 및 다운로드 제한 ###########

$index = "17"
$title = "IIS 파일 업로드 및 다운로드 제한"
$result_act = $false
$RV = "업로드 / 다운로드 용량을 제한"
$importance = "상"

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

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

########### 18. IIS DB 연결 취약점 점검 ###########

$index = "18"
$title = "IIS DB 연결 취약점 점검"
$result_act = $false
$RV = ".asa 매핑 시 특정 동작 설정 / .asa 매핑 존재X"
$importance = "상"

$IIS_Site_List = Get-IISSite | select-Object Name
$flag_asa = 0
$flag_asax = 0

$total_web_count = 0

$tempSTR = @()

for ($X = 0; $X -lt $Site_Name_list.count; $X++) {
    $flag_asa = (Get-WebHandler -PSPath $Site_Path_list[$X] | Where-Object { $_.Path -eq "*.asa" }).count
    if ($flag_asa -eq 1) {
        #echo($Site_Name + "사이트 처리기 매핑에 *.asa 매핑이 등록되어 있습니다. - 취약")
    }

    $flag_asax = (Get-WebHandler -PSPath $Site_Path_list[$X] | Where-Object { $_.Path -eq "*.asax" }).count
    if ($flag_asax -eq 1) {
        #echo($Site_Name_list[$X] + "사이트 처리기 매핑에 *.asax 매핑이 등록되어 있습니다. - 취약")
    }

    if ($flag_asa -eq 0 -and $flag_asax -eq 0) {
        #echo($Site_Name_list[$X] + "사이트는 처리기 매핑에 *asa , *.asax 매핑이 모두 등록되어 있지 않습니다. - 양호")
    }
    else {
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
    $CV = ($tempSTR + " 사이트에서 .asa 혹은 .asax 매핑 처리X")
}
else {
    $result = "양호"
    $CV = ("모든 사이트에서 .asa 혹은 .asax 매핑 처리O")
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

########### 19. IIS 가상 디렉토리 삭제 ###########

$index="19"
$title="IIS 가상 디렉토리 삭제"
$result_act = $false
$RV = "IIS Admin, IIS Adminpwd 가상 디렉토리 존재X"
$importance = "상"

$total_web_count = 0

$tempSTR = @()

# IIS 6.0 이상
if($IIS_version -ge 6)
{
    $CV = "IIS 6.0 버전 이상은 해당X"
    $result = "양호"
}

# IIS 6.0 미만
elseif($IIS_version -lt 6)
{
    for($X=0;$X -lt $Site_Name_list.count;$X++)
    {
        $flag_admin = (Get-ChildItem $Site_Path_list[$X] | Where-Object {$_.Name -eq "IIS Admin"}).count
        if($flag_admin -gt 0)
        {
            #echo($Site_Name_list[$X] + "사이트에 IIS Admin 가상 디렉토리가 존재합니다. - 취약")
        }

        $flag_adpwd = (Get-ChildItem $Site_Path_list[$X] | Where-Object {$_.Name -eq "IIS Adminpwd"}).count
        if($flag_adpwd -gt 0)
        {
            #echo($Site_Name_list[$X] + "사이트에 IIS Adminpwd 가상 디렉토리가 존재합니다. - 취약")
        }

        if($flag_admin -eq 0 -and $flag_adpwd -eq 0)
        {
            #echo($Site_Name_list[$X] + "사이트에는 IIS Admin, IIS Adminpwd 가상 디렉토리가 존재하지 않습니다. - 양호")
        }
        else 
        {
            $tempSTR += $Site_Name_list[$X]
            $tempSTR += ','

            $total_web_count++   
        }

    }

    if($tempSTR.count -gt 0)
    {
        $tempSTR[-1] = ''
    }


    if($total_web_count -gt 0)
    {
        $CV = ($tempSTR + " 사이트에서 가상 디렉토리 발견")
        $result = "취약"
    }
    else
    {
        $CV = ("모든 사이트에서 가상 디렉토리 미발견")
        $result = "양호"
    }
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

########### 20. IIS 데이터 파일 ACL 적용 ###########


$index = "20"
$title = "IIS 데이터 파일 ACL 적용"
$result_act = $false
$RV = "홈 디렉토리 하위 모든파일에 Everyone 권한 존재X"
$importance = "상"
$total_web_count = 0

$tempSTR = @()

#$IIS_Site_List = Get-IISSite | select-Object Name
for ($X = 0; $X -lt $Site_Name_list.count; $X++) {
    $Path_child_items = (Get-ChildItem -Path $Site_Path_list[$X] -Recurse).FullName
    $Everyone_Access_files_count = 0

    foreach ($file_item in $Path_child_items) {
        $Everyone_Access_count = (Get-Permissions -Path $file_item | Where-Object { $_.IdentityReference -like "*Everyone*" }).Count

        if ($Everyone_Access_count -gt 0) {
            #해당 사이트 Everyone 권한 허용 파일 갯수 증가
            $Everyone_Access_files_count++

        }
    }

    if ($Everyone_Access_files_count -eq 0) {
        #echo($Site_Name_list[$X] + " 사이트 홈 디렉토리 내부에는 Everyone 권한을 가진 파일이 존재하지 않습니다. - 양호`n")
    }
    else {
        $tempSTR += $Site_Name_list[$X]
        $tempSTR += ','

        $total_web_count++
        #echo($Site_Name_list[$X] + " 사이트 홈 디렉토리에서는 " + "Everyone 권한을 가진 파일이 " + $Everyone_Access_files_count + "개 존재합니다. - 취약")
    }

}

if ($tempSTR.count -gt 0) {
    $tempSTR[-1] = ''
}


if ($total_web_count -gt 0) {
    $CV = ("홈 디렉토리 하위 파일에 Everyone 권한이 존재하는 사이트는 " + $tempSTR + " 입니다.")
    $result = "취약"
}
else {
    $CV = ("모든 사이트의 홈 디렉터리 하위 파일에 Everyone 권한 존재X")
    $result = "양호"
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

######################################################

########### 21. IIS 미사용 스크립트 매핑 제거 ###########


$index = "21"
$title = "IIS 미사용 스크립트 매핑 제거"
$result_act = $false
$RV = "취약한 매핑 존재X"
$importance = "상"
$total_web_count = 0
$tempSTR = @()

$unsafe_mapping_list = @("*.htr*", "*.idc*", "*.stm*", "*.shtm*", "*.printer*", "*.htw*", "*.ida*", "*.idq*")

for ($X = 0; $X -lt $Site_Name_list.count; $X++) {
    $unsafe_mapping_count = 0

    foreach ($mapping_item in $unsafe_mapping_list) {
        $flag = (Get-WebHandler -PSPath $Site_Path_list[$X] | Where-Object { $_.Path -like ($mapping_item) }).count

        if ($flag -eq 1) {
            $unsafe_mapping_count++

            $mapping_item = $mapping_item.split('*')
            #echo($Site_Name_list[$X] + "사이트 처리기 매핑에 " + "*" + $mapping_item[1] +" 매핑이 등록되어 있습니다. - 취약")
        }
    }

    if ($unsafe_mapping_count -eq 0) {
        #echo($Site_Name_list[$X] + " 사이트에서는 취약한 매핑이 존재하지 않습니다. - 양호`n")
    }
    else {
        $tempSTR += $Site_Name_list[$X]
        $tempSTR += ','

        $total_web_count++
        #echo($Site_Name_list[$X] + " 사이트에서는 총 " + $unsafe_mapping_count +"개의 취약한 매핑이 존재합니다. - 취약`n")
    }
   
}

if ($tempSTR.count -gt 0) {
    $tempSTR[-1] = ''
}

if ($total_web_count -gt 0) {
    $CV = ("취약한 매핑이 존재하는 사이트는 " + $tempSTR + " 입니다.")
    $result = "취약"
}
else {
    $CV = ("모든 사이트에 취약한 매핑 존재X")
    $result = "양호"
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

########### 23. IIS WebDAV 비활성화 ###########

$index = "23"
$title = "IIS WebDAV 비활성화"
$result_act = $true
$RV = "IIS 서비스 미 사용 or DisableWebDAV 값 1"
$importance = "상"

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

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

########### 24. NetBIOS 바인딩 서비스 구동 점검 ###########


$index = "24"
$title = "NetBIOS 바인딩 서비스 구동 점검"
$result = "수동"
$result_act = $false
$RV = "TCP/IP - NetBIOS 간의 바인딩 제거"
$importance = "상"

# WMI를 사용하여 네트워크 어댑터의 NetBIOS 설정 확인
$adapter = Get-WmiObject -Query "SELECT * FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled = True"
$netbiosSetting = $adapter.TcpipNetbiosOptions

# NetBIOS 설정에 따른 결과 출력
if ($netbiosSetting -eq 0) {
    # 기본값 설정 (DHCP에 따라 설정)
    $CV = "NetBIOS가 기본값으로 설정되어 있습니다."
    $result = "취약"
}
elseif ($netbiosSetting -eq 1) {
    # NetBIOS 사용
    $CV = "NetBIOS가 TCP/IP를 통해 사용됩니다."
    $result = "취약"
}
elseif ($netbiosSetting -eq 2) {
    # NetBIOS 사용 안 함
    $CV = "NetBIOS가 TCP/IP를 통해 사용되지 않습니다."
    $result = "양호"
}
else {
    # 예외 처리
    $CV = "NetBIOS 설정을 확인할 수 없습니다."
    $result = "수동"
}

# https://getadmx.com/?Category=Windows_10_2016&Policy=Microsoft.Policies.NetLogon::Netlogon_AvoidFallbackNetbiosDiscovery

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

########### 25. FTP 서비스 구동 점검 ###########


$index = "25"
$title = "FTP 서비스 구동 점검"
$result_act = $true
$RV = "FTP 사용X or secure FTP 사용"
$importance = "상"

$flag = (Get-Service | Where-Object { $_.Name -like "*Microsoft FTP Service*" -and $_.Status -eq "Running" }).Count

if ($flag -gt 0) {
    $result = "취약"
    $CV = "FTP 서비스를 사용 중 입니다."
}
else {
    $result = "양호"
    $CV = "FTP 서비스를 사용하지 않습니다."
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################