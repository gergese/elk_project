function Test-Role
{
    Param([Security.Principal.WindowsBuiltinRole]$Role )
    $CurrentUser = [Security.Principal.WindowsPrincipal]([Security.Principal.WindowsIdentity]::GetCurrent())
    $CurrentUser.IsInRole($Role)
}

# 공백 / 줄바꿈이 존재하는 object형 결과값을 공백없는 String형 결과값으로 바꿔주는 함
function String([object]$string)
{
    $string_return = Out-String -InputObject $string
    $string_return = $string_return.Split(" ")[0]
    $string_return = $string_return.Split("`r")[2]
    $string_return = $string_return.Split("`n")[1]

    return $string_return
}

# 경로의 권한을 얻어온다.
function Get-Permissions($Path)
{
    (Get-Acl -Path $Path).Access | select 
    @{Label="identity"; Expression={$_.IdentityReference}}
}

# 레지스트리 키 이름, 타입, 값을 출력해준다.
function Get-RegistryValue
{
    param
    (
        [Parameter(Mandatory = $true)]
        $RegistryKey
    )

    $key = Get-Item -Path "Registry::$RegistryKey"
    $key.GetValueNames() |
    ForEach-Object {
        $name = $_
        $rv = 1 | Select-Object -Property Name, Type, Value
        $rv.Name = $name
        $rv.Type = $key.GetValueKind($name)
        $rv.Value = $key.GetValue($name)
        $rv
  
    }
}

# 입력된 경로의 레지스트리 키가 존재하는지 확인한다.
function Test-RegistryValue($regkey, $name) 
{
    try
    {
        $exists = Get-ItemProperty $regkey $name -ErrorAction SilentlyContinue
        if (($exists -eq $null) -or ($exists.Length -eq 0))
        {
            return $false
        }
        else
        {
            return $true
        }
    }
    catch
    {
        return $false
    }
}

#SID를 계정이름으로 변경해준다.
function Convert_SID_TO_USERNAME($SID)
{
    $objSID = New-Object System.Security.Principal.SecurityIdentifier($SID)
    $objUser = $objSID.Translate( [System.Security.Principal.NTAccount])
    return ($objUser.Value)
}

# 문서화를 위한 결과 저장 변수
$index=0
$root_title="서비스 관리"
$title=0
$result=0

#################################################### < 2 . 서비스 관리 > ####################################################
#############################################################################################################################

#################### IIS 서비스 관련 취약점 점검에 자주 사용되는 IIS 버전은 미리 구해둔다. ####################
try{
$IIS_version = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\InetStp\  | select setupstring | Format-Wide

# Object형 결과 값 String형으로 변환
$IIS_version = Out-String -InputObject $IIS_version

# "IIS xxx" 부분에서 숫자 부분 출력
$IIS_version = $IIS_version.Split(" ")[1]

# String형 값 -> INT 형으로 바꾸기
$IIS_version = $IIS_version -as [int]
}
catch{}
#############################################################################################################

#################### IIS 사이트 이름과 경로는 자주 점검에 자주 사용되므로 미리 구해둔다. ####################

$IIS_Site_List = Get-IISSite | select-Object Name

$Site_Name_list=@()
$Site_Path_list=@()
$Site_Path_Full_Path_list=@()

foreach($name_item in $IIS_Site_List)
{
    $name_item = $name_item | Format-Wide

    # 공백 , newline 문자열을 버리고 이름만 추출
    $Site_Name = String $name_item
    $Site_Name_list += $Site_Name

    $Site_Path = 'IIS:\Sites\' + $Site_Name
    $Site_Path_list += $Site_Path

    # 드라이브 이름으로 시작하는 (EX : C\..) 실제 경로
    $Site_Path = (Get-WebFilePath $Site_Path).FullName
    $Site_Path_Full_Path_list += $Site_Path

}

#############################################################################################################

#################### FTP 사이트 이름과 경로는 자주 점검에 자주 사용되므로 미리 구해둔다. ####################

$FTP_Site_List = Get-IISSite | Where-Object {$_.Bindings -like "*ftp*"} | select-Object Name

$FTP_Site_Name_list=@()
$FTP_Site_Path_list=@()
$FTP_Site_Path_Full_Path_list=@()

foreach($name_item in $FTP_Site_List)
{
    $name_item = $name_item | Format-Wide

    # 공백 , newline 문자열을 버리고 이름만 추출
    $Site_Name = String $name_item
    $FTP_Site_Name_list += $Site_Name

    $Site_Path = 'IIS:\Sites\' + $Site_Name
    $FTP_Site_Path_list += $Site_Path

    # 드라이브 이름으로 시작하는 (EX : C\..) 실제 경로
    $Site_Path = (Get-WebFilePath $Site_Path).FullName
    $FTP_Site_Path_Full_Path_list += $Site_Path

}

#############################################################################################################

###### 7. 공유 권한 및 사용자 그룹 설정 ######

$index="07"
$title="공유 권한 및 사용자 그룹 설정"

$RV = "일반 공유 디렉토리 X / 접근 권한에 Everyone 권한이 없음"
$importance = "상"

# 모든 공유 폴더를 가져옵니다
$shares = Get-SmbShare

foreach ($share in $shares) {
    # 공유 폴더의 현재 접근 권한 정보를 가져옵니다.
    $accessList = Get-SmbShareAccess -Name $share.Name
    
    foreach ($access in $accessList) {
        if ($access.AccountName -eq 'Everyone') {
            # Everyone 권한을 제거합니다.
            Revoke-SmbShareAccess -Name $share.Name -AccountName "Everyone" -Force
        }
    }
}

$CV = "Everyone 권한이 모든 공유 폴더에서 제거되었습니다."
Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV

###############################################

###### 8. 하드디스크 기본 공유 제거 취약 ######

$index="08"
$title="하드디스크 기본 공유 제거 취약"

$RV = "AutoShareServer 값이 0 & 기본 공유가 존재X"
$importance = "상"

# # IPC$를 제외한 기본 공유 폴더가 존재하는지 확인
# $DefaultSmbInfo = @(Get-SmbShare | Where-Object {$_.Name -ne "IPC$"} |Where-Object {$_.Name -like "*$"})
# $var = $DefaultSmbInfo.Length

# 레지스트리 경로 정의
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters"

# 기본 공유 폴더 공유 중지 설정 (자동 관리 공유 비활성화)
Set-ItemProperty -Path $regPath -Name "AutoShareWks" -Value 0 -Force
Set-ItemProperty -Path $regPath -Name "AutoShareServer" -Value 0 -Force

# 메시지 출력
$CV = "기본 공유 폴더가 비활성화되었습니다. 시스템을 재부팅해야 변경 사항이 적용됩니다."
Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV
# Write-Host ($index + "#" + $root_title + +"#" + $title + "#" + "기본 공유 폴더가 비활성화되었습니다. 시스템을 재부팅해야 변경 사항이 적용됩니다.") >> action_result.txt

###############################################

########### 9. 불필요한 서비스 제거 ###########

$index="09"
$title="불필요한 서비스 제거"

$RV = "일반적으로 불필요한 서비스들을 중지"
$importance = "상"

# 서비스 목록이 포함된 파일 경로
$serviceListPath = ".\Needless_Services_list.txt"

# 서비스 목록을 파일에서 읽기
$serviceNames = Get-Content -Path $serviceListPath

# 각 서비스에 대해
foreach ($serviceName in $serviceNames) {
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
Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV
# Write-Host ($index + "#" + $root_title + +"#" + $title + "#" + "불필요한 서비스 모두 중지되었습니다.") >> action_result.txt

###############################################

########### 11. 디렉토리 리스팅 제거 ###########

$index="11"
$title="디렉토리 리스팅 제거"

$RV = " 디렉토리 검색 옵션 해제"
$importance = "상"

$Site_List = Get-ChildItem IIS:\Sites | select -expand Name

$PSPath = 'MACHINE/WEBROOT/APPHOST'
$Filter = 'system.webServer/directoryBrowse'
$Name = 'enabled'

foreach($Location in $Site_List)
{
    # 디렉터리 검색 설정 비활성화
    Set-WebConfigurationProperty -PSPath $PSPath$Location -Filter $Filter -Name $Name -Value $false
}

$CV = "사이트의 디렉터리 검색이 사용 안 함으로 설정되었습니다."
Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV
# Write-Host ($index + "#" + $root_title + +"#" + $title + "#" + "사이트의 디렉터리 검색이 사용 안 함으로 설정되었습니다.") >> action_result.txt

###############################################

######### 12. IIS CGI 실행 제한 양호 #########

$index="12"
$title="IIS CGI 실행 제한 양호"

$RV = "Everyone에 권한이 없는 경우"
$importance = "상"

$var = Test-Path -Path "C:\inetpub\scripts"

# Everyone 권한 제거
icacls $var /remove "Everyone"

###############################################

########### 13. IIS 상위 디렉토리 접근 금지 ###########

$index="13"
$title="IIS 상위 디렉토리 접근 금지"

$RV = "상위 패스 기능 제거"
$importance = "상"

$Site_List = Get-ChildItem IIS:\Sites | select -expand Name

$PSPath = 'MACHINE/WEBROOT/APPHOST'
$Filter = 'system.webServer/asp'
$Name = 'enableParentPaths'

foreach($Location in $Site_List)
{
    Set-WebConfigurationProperty -PSPath $PSPath -Location $Location -Filter $Filter -Name $Name -Value "False"
}

$CV = "상위 디렉토리 접근 기능 False로 설정"
Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV
# Write-Host ($index + "#" + $root_title + +"#" + $title + "#" + "상위 디렉토리 접근 기능 False로 설정") >> action_result.txt

###############################################

########### 16. IIS 링크 사용 금지 ###########

$index="16"
$title="IIS 링크 사용 금지"
$importance = "상"

$RV = "바로가기(.lnk) 파일의 사용 허용X"

for($X=0; $X -lt $Site_Name_list.count; $X++)
{
    # 각 사이트 경로에서 .lnk 파일을 재귀적으로 찾는다
    $lnkFiles = Get-ChildItem $Site_Path_list[$X] -Recurse | Where-Object {$_.Extension -eq ".lnk"}
    
    # 링크 파일이 있으면 삭제한다
    foreach ($file in $lnkFiles) {
        Remove-Item $file.FullName -Force
    }
}

$CV = "바로가기 파일 모두 제거"
Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV
# Write-Host ($index + "#" + $root_title + +"#" + $title + "#" + "바로가기 파일 모두 제거") >> action_result.txt

###############################################

########### 17. IIS 파일 업로드 및 다운로드 제한 ###########

$index="17"
$title="IIS 파일 업로드 및 다운로드 제한"

$RV = "업로드 / 다운로드 용량을 제한"
$importance = "상"

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
Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV
# Write-Host ($index + "#" + $root_title + +"#" + $title + "#" + "업로드/다운로드 제한 설정") >> action_result.txt

###############################################

########### 18. IIS DB 연결 취약점 점검 ###########

$index="18"
$title="IIS DB 연결 취약점 점검"

$RV = ".asa 매핑 시 특정 동작 설정 / .asa 매핑 존재X"
$importance = "상"

$Site_List = Get-ChildItem IIS:\Sites | select -expand Name
$PSPath = 'MACHINE/WEBROOT/APPHOST'
$Filter = 'system.webServer/security/requestFiltering/fileExtensions'
$Extensions = @(".asa", ".asax")

foreach($Location in $Site_List)
{
    foreach ($ext in $Extensions) {
        # 특정 확장자 요청 필터링 설정 확인
        $existing = Get-WebConfigurationProperty -PSPath $PSPath$Location -Filter $Filter -Name "Collection" | Where-Object {$_.FileExtension -eq $ext}

        if ($existing) {
            # 이미 설정된 경우, 필터링 허용을 false로 변경
            Set-WebConfigurationProperty -PSPath $PSPath -Location $Location -Filter "$Filter/add[@fileExtension='$ext']" -Name "allowed" -Value "false"
            Write-Host "$ext 확장자에 대한 요청 필터링이 비활성화되었습니다: $Location"
        } else {
            # 설정이 없는 경우 추가
            Add-WebConfigurationProperty -PSPath $PSPath -Location $Location -Filter $Filter -Name "Collection" -Value @{fileExtension=$ext;allowed="false"}
            Write-Host "$ext 확장자에 대한 요청 필터링이 추가되었습니다: $Location"
        }
    }
}

$CV = ".asa, .asax에 대한 필터링 설정"
Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV
# Write-Host ($index + "#" + $root_title + +"#" + $title + "#" + ".asa, .asax에 대한 필터링 설정") >> action_result.txt

###############################################

########### 20. IIS 데이터 파일 ACL 적용 ###########


$index="20"
$title="IIS 데이터 파일 ACL 적용"

$RV = "홈 디렉토리 하위 모든파일에 Everyone 권한 존재X"
$importance = "상"

#$IIS_Site_List = Get-IISSite | select-Object Name
for($X=0;$X -lt $Site_Name_list.count;$X++)
{
    # 각 사이트 경로에서 모든 파일 및 디렉토리를 재귀적으로 가져옴
    $Path_child_items = (Get-ChildItem -Path $Site_Path_list[$X] -Recurse).FullName
    
    foreach($file_item in $Path_child_items)
    {
        # 파일 또는 폴더의 권한 정보 가져오기
        $acl = Get-Acl -Path $file_item
        
        # Everyone 권한 필터링
        $everyone_acl = $acl.Access | Where-Object {$_.IdentityReference -eq "Everyone"}
        
        foreach ($rule in $everyone_acl) {
            # Everyone 권한 제거
            $acl.RemoveAccessRule($rule)
        }
            
        # 변경된 권한을 파일에 적용
        Set-Acl -Path $file_item -AclObject $acl
        Write-Host "Everyone 권한이 제거되었습니다: $file_item"
    }
}

$CV = "Everyone 권한 제거"
Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV
# Write-Host ($index + "#" + $root_title + +"#" + $title + "#" + "Everyone 권한 제거") >> action_result.txt

###############################################

########### 21. IIS 미사용 스크립트 매핑 제거 ###########

$index="21"
$title="IIS 미사용 스크립트 매핑 제거"

$RV = "취약한 매핑 존재X"
$importance = "상"

$unsafe_mapping_list = @("*.htr*","*.idc*","*.stm*","*.shtm*","*.printer*","*.htw*","*.ida*","*.idq*")

for($X=0; $X -lt $Site_Name_list.count; $X++)
{
    # 각 사이트의 경로를 가져옴
    $sitePath = $Site_Path_list[$X]

    foreach($mapping_item in $unsafe_mapping_list)
    {
        # 특정 매핑을 검색
        $handlers = Get-WebHandler -PSPath $sitePath | Where-Object {$_.Path -like $mapping_item}

        # 매핑이 존재하면 제거
        if ($handler.Name) {  # Name이 null이 아닐 경우에만 제거
            Remove-WebHandler -PSPath $sitePath -Name $handler.Name -Force
        }
    }
}

$CV = "미사용 스크립트 매핑 제거"
Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV
# Write-Host ($index + "#" + $root_title + +"#" + $title + "#" + "미사용 스크립트 매핑 제거") >> action_result.txt

###############################################

########### 23. IIS WebDAV 비활성화 ###########

$index="23"
$title="IIS WebDAV 비활성화"

$RV = "IIS 서비스 미 사용 or DisableWebDAV 값 1"
$importance = "상"

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
Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV
# Write-Host ($index + "#" + $root_title + +"#" + $title + "#" + "WebDAV 제한 설정") >> action_result.txt

###############################################

########### 24. NetBIOS 바인딩 서비스 구동 점검 ###########


$index="24"
$title="NetBIOS 바인딩 서비스 구동 점검"
$result = "수동"

$RV = "TCP/IP - NetBIOD 간의 바인딩 제거"
$importance = "상"

# IP가 활성화된 네트워크 어댑터 구성 가져오기
$adapter = Get-WmiObject -Query "SELECT * FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled = True"

# 각 어댑터에 대해 반복
foreach ($item in $adapter) {
    # 현재 NetBIOS 설정 확인
    $currentNetbiosSetting = $item.TcpipNetbiosOptions

    # NetBIOS 설정을 2로 변경
    $result = $item.SetTcpipNetbios(2)
}

$CV = "NetBIOS TCP/IP간 바인딩 제거"
Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV
# Write-Host ($index + "#" + $root_title + +"#" + $title + "#" + "NetBIOS TCP/IP간 바인딩 제거") >> action_result.txt

###############################################

########### 25. FTP 서비스 구동 점검 ###########


$index="25"
$title="FTP 서비스 구동 점검"

$RV = "FTP 사용X or secure FTP 사용"
$importance = "상"

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
Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV
# Write-Host ($index + "#" + $root_title + +"#" + $title + "#" + "FTP 구동 중지") >> action_result.txt

###############################################