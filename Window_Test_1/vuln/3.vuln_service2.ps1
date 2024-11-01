﻿#############################################################################################################



$index=0
$root_title="서비스 관리"
$title=0
$result=0

########### 26. FTP 디렉토리 접근권한 설정 ###########

$index="26"
$title="FTP 디렉토리 접근권한 설정"
$result_act = $true
$RV = "FTP 홈 디렉토리에 Everyone 권한이 없는 경우"
$importance = "상"

$total_web_count = 0

$tempSTR = @()

if($FTP_Site_List.length -ne 0)
{
    for($X=0;$X -lt $FTP_Site_Name_list.count;$X++)
    {
            $Everyone_Access = (Get-Permissions -Path $FTP_Site_Path_Full_Path_list[$X] | Where-Object {$_.IdentityReference -like "*Everyone*"}).Count
        
            if($Everyone_Access -eq 0)
            {
                #echo($FTP_Site_Name_list[$X] + " 사이트 홈 디렉토리에 Everyone 권한이 존재하지 않습니다. - 양호")
            }
            else
            {                
                $total_web_count++
                $tempSTR += $FTP_Site_List[$X]
                $tempSTR += ','

                #echo($FTP_Site_Name_list[$X] + " 사이트 홈 디렉토리에 Everyone 권한이 존재합니다. - 취약")
            }
    }

    if($tempSTR.count -gt 0)
    {
        $tempSTR[-1] = ''
    }

    if($total_web_count -gt 0)
    {
        $result = "취약"
        $CV = ("홈 디렉토리에 Everyone 권한이 존재하는 FTP 사이트는 "+ $tempSTR +"입니다.")
    }
    else
    {
        $result = "양호"
        $CV = ("홈 디렉토리에 Everyone 권한이 존재하는 FTP 사이트는 없습니다.")
    }
}
else
{
    $result = "양호"
    $CV = "FTP 사이트를 사용하지 않습니다."
    #echo("FTP 사이트를 사용하지 않습니다. - 양호")
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

########### 27. Anonymous FTP 금지 ###########


$index="27"
$title="Anonymous FTP 금지"
$result_act = $true
$RV = "FTP 서비스 사용X or 익명 연결 허용 옵션을 해제"
$importance = "상"

$total_web_count = 0

$tempSTR = @()

# FTP 사이트가 존재할 경우
if($FTP_Site_List.length -ne 0)
{
    for($X=0;$X -lt $FTP_Site_Name_list.count;$X++)
    {
        $Web_Property_Filter = "/system.webServer/security/authentication/anonymousAuthentication"

        $Everyone_Access = Get-WebConfigurationProperty -Filter $Web_Property_Filter -name enabled  -PSPath $FTP_Site_Path_list[$X] | Select-Object "Value"

        if($Everyone_Access -like "*True*")
        {
            $total_web_count++
            $tempSTR += $FTP_Site_Name_list[$X]
            $tempSTR += ','
        }

    }
    
    if($tempSTR.count -gt 0)
    {
        $tempSTR[-1] = ''
    }

    if($total_web_count -gt 0)
    {
        $result = "취약"
        $CV = ("Anonymous 로그인이 허용된 FTP 사이트는 " + $tempSTR + " 입니다.")
    }
    else
    {
        $result = "양호"
        $CV = ("홈 디렉토리에 Everyone 권한이 존재하는 FTP 사이트는 없습니다.")
    }
}
# FTP 사이트가 존재하지 않을 경우
else
{
    $result = "양호"
    $CV = "FTP 사이트를 사용하지 않습니다."
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

########### 28. FTP 접근 제어 설정 ###########


$index="28"
$title="FTP 접근 제어 설정"
$result_act = $false
$total_web_count = 0

$tempSTR = @()

$importance = "상"

# FTP 사이트가 존재할 경우
if($FTP_Site_List.length -ne 0)
{
    for($X=0;$X -lt $FTP_Site_Name_list.count;$X++)
    {
        $Web_Property_Filter = "/system.ftpserver/security/ipsecurity"

        $Everyone_Access = Get-WebConfigurationProperty -Filter $Web_Property_Filter -name allowUnlisted  -PSPath $FTP_Site_Path_list[$X] | Select-Object "Value"

        if($Everyone_Access -like "*True*")
        {
            $total_web_count++
            $tempSTR += $FTP_Site_Name_list[$X]
            $tempSTR += ','

        }

    }

    if($tempSTR.count -gt 0)
    {
        $tempSTR[-1] = ''
    }

    if($total_web_count -gt 0)
    {
        $result = "취약"
        $CV = ("접근 제어를 설정하지 않은 FTP 사이트는 " + $tempSTR + " 입니다.")
    }
    else
    {
        $result = "양호"
        $CV = ("접근 제어를 설정하지 않은 FTP 사이트는 없습니다.")
    }
}
# FTP 사이트가 존재하지 않을 경우
else
{
    $result = "양호"
    $CV = "FTP 사이트를 사용하지 않습니다."
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

########### 29. DNS Zone Transfer 설정 ###########


$index="29"
$title=" DNS Zone Transfer 설정"
$result_act = $false
$RV = "DNS 서비스 사용X / 영역 전송 허용X / 특정 서버로만 설정"
$importance = "상"

$result = "수동"
$CV = "DNS 서버 사용 여부 확인 필요"
# $total_dns_count = 0

# $tempSTR = @()
# try {
#     $DNS_Zone_list = Get-DnsServerZone | Select-Object ZoneName

#     $flag = Get-Service *DNS* | Select-Object "Status"

#     if($flag -like "*Running*")
#     {
#         if($DNS_Zone_list.length -gt 0)
#         {
#             foreach($zone_item in $DNS_Zone_list)
#             {
#                 $zone_item = $zone_item | Format-Wide
#                 $Zone_Name = String $zone_item
             
#                 $flag = (Get-DnsServerZone -ZoneName $Zone_Name).SecureSecondaries

#                 if($flag -like "*NoTransfer*")
#                 {
#                     $result = "양호" 
#                 }
#                 elseif($flag -like "*TransferToSecureServers*")
#                 {
#                     $result = "양호"
#                 }
#                 elseif($flag -like "*TransferToZoneNameServer*")
#                 { 
#                     $result = "취약"
#                     $total_dns_count++
#                     $tempSTR += $Zone_Name
#                     $tempSTR += ','
#                 }
#                 elseif($flag -like "*TransferAnyServer*")
#                 {
#                     $result = "취약"
#                     $total_dns_count++
#                     $tempSTR += $Zone_Name
#                     $tempSTR += ','
#                 }
#             }
#             if($tempSTR.count -gt 0)
#             {
#                 $tempSTR[-1] = ''  
#             }
#         }
#         else
#         {
#             $result = "양호"
#         }

#         if($total_dns_count -gt 0)
#         {
#             $CV = ("DNS Zone Transfer 차단 설정이 되어 있지 않은 Zone은 " + $tempSTR + " 입니다.")
#             $result = "취약"
#         }
#         else
#         {
#             $CV = ("모든 Zone이 차단 설정이 되어 있습니다.")
#             $result = "양호"
#         }
#     }
# }
# catch {
#     $CV = "해당 서버는 DNS 관련 서비스를 사용하고 있지 않습니다."
#     $result = "양호"
# }

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

# 특정 DNS 도메인 상세 확인
#Get-DnsServerZone -ZoneName 0.in-addr.arpa | Format-List

# 특정 도메인 영역 전송 옵션 설정
#Set-DnsServerPrimaryZone -Name $ sec.ZoneName -SecureSecondaries TransferToSecureServers
# NoTransfer : 영역 전송 사용 X
# TransferAnyServer : 영역 전송 사용 O, 아무 서버로
# TransferToZoneNameServer : 영역 전송 사용 O, 이름 서버 탭에 나열된 서버로만
# TransferToSecureServers : 영역 전송 사용 O, 다음 서버로만 (특정 서버를 지정하여 설정)

###############################################

########### 30. 최신 서비스 팩 적용 ###########

$index="30"
$title="RDS(Remote Data Services) 제거"
$result_act = $false
$RV = "IIS 사용X / Windows 2000 서비스팩 4, Windows 2003 서비스팩 2 이상 설치 / Default 웹 사이트에 MSADC 가상 디렉토리 존재X"
$importance = "상"

$WIn_version = [Environment]::OSVersion.Version | Select-Object Major | Format-Wide
$WIn_version = String $WIn_version
$WIn_version = $WIn_version -as [int]

if($WIn_version -ge 6)
{
    $result = "양호"
    $CV = "윈도우 2008 이상 OS 버전"
}

else
{
    $result = "수동"
    $CV = "윈도우 2003 이하 OS 버전"
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

########### 31. 최신 서비스 팩 적용 ###########

$index="31"
$title="최신 서비스 팩 적용"
$result_act = $false
$RV = "최신 서비스 팩이 설치"
$importance = "상"

# CIM을 통해 시스템에 설치된 업데이트 정보 가져오기
$updates = Get-CimInstance -ClassName Win32_QuickFixEngineering

# 업데이트 목록이 존재하는지 확인
if ($updates.Count -gt 0) {
    $result = "수동"
    $CV = "윈도우 서비스 팩이 최신 버전이 아닙니다."
} else {
    $result = "양호"
    $CV = "윈도우 서비스 팩이 최신 버전입니다."
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV
 
###############################################

########### 58. 터미널 서비스 암호화 수준 설정 ###########

$index="58"
$title="터미널 서비스 암호화 수준 설정"
$importance = "중"
$RV = "터미널 서비스 사용X / 암호화 수준 '클라이언트와 호환 가능(중간)' 이상으로 설정"
$result_act = $true

# 레지스트리 키 확인
$key = "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp"
$value = "MinEncryptionLevel"

# 그룹 정책 상태 확인
if (Test-Path $key) {
    # 구성된 경우 설정 상태 확인
    $policy = Get-ItemProperty -Path $key -Name $value -ErrorAction SilentlyContinue

    if ($policy) {
        # 암호화 수준 출력
        $encryptionLevel = $policy.MinEncryptionLevel
        switch ($encryptionLevel) {
            1 { $CV = "암호화 수준: 낮은 수준" }
            2 { $CV = "암호화 수준: 클라이언트 호환 가능" }
            3 { $CV = "암호화 수준: 높은 수준" }
            default { $CV = "알 수 없는 암호화 수준" }
        }
        $result = "양호"
    } else {
        $CV = "암호화 수준 설정이 존재하지 않음"
        $result = "취약"
    }

    # 사용/사용 안 함/구성되지 않음 확인
    $policyStatus = Get-ItemProperty -Path $key
    if ($policyStatus -eq $null) {
        $CV = "정책 상태: 사용 안 함 또는 구성되지 않음"
        $result = "취약"
    }
} else {
    $CV = "정책 상태: 구성되지 않음"
    $result = "취약"
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

########### 59. IIS 웹 서비스 정보 숨김 ###########

$index="59"
$title="IIS 웹 서비스 정보 숨김"
$result_act = $false
$RV = "웹 서비스의 에러 페이지를 별도로 지정한다."
$importance = "중"

$total_web_count = 0

$tempSTR = @()

for($X=0;$X -lt $Site_Name_list.count;$X++)
{
    $Web_Property_Filter = "/system.webserver/httpErrors"
    $Error_Mode = Get-WebConfigurationProperty -Filter $Web_Property_Filter -name errormode -PSPath $Site_Path_list[$X]

    if($Error_Mode -like "*DetailedLocalOnly*")
    {
        $result = "취약"
        $total_web_count++
        $tempSTR += $Site_Name_list[$X]
        $tempSTR += ','
    }
    elseif($Error_Mode -like "Detailed")
    {
        $result = "취약"
        $total_web_count++
        $tempSTR += $Site_Name_list[$X]
        $tempSTR += ','
    }
    elseif($Error_Mode -like "*Custom*")
    {
        $result = "양호"
    }

}

if($tempSTR.count -gt 0)
{
    $tempSTR[-1] = ''
}

if($total_web_count -gt 0)
{
    $CV = ("사용자 지정 에러 페이지를 별도로 지정하지 않은 사이트는 " + $tempSTR + "입니다.")
    $result = "취약"
}
else
{
    $CV = ("모든 사이트에 사용자 지정 에러 페이지 지정 설정")
    $result = "양호"
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

########### 60. SNMP 서비스 구동 점검 ###########

$index="60"
$title="SNMP 서비스 구동 점검"

$RV = "SNMP 서비스 사용하지 않는 경우"
$importance = "중"

$flag = (Get-Service -Name *SNMP* | Where-Object {$_.Status -like "*Running*"}).count

if($flag -gt 0)
{
    $result = "취약"
    $CV = "SNMP가 현재 실행 중"
}
else
{
    $result = "양호"
    $CV = "SNMP가 현재 동작하지 않는다."
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

########### 61. SNMP 서비스 커뮤니티 스트링의 복잡성 설정 ###########

$index="61"
$title="SNMP 서비스 커뮤니티 스트링의 복잡성 설정"

$RV = "SNMP 서비스 사용X / Community String 이 public 혹은 private 가 아님"
$importance = "중"

$flag = (Get-Service -Name *SNMP* | Where-Object {$_.Status -like "*Running*"}).count
$count = 0

$tempSTR = @()

if($flag -gt 0)
{
    $Community_Strings = Get-RegistryValue "HKLM\SYSTEM\CurrentControlSet\services\SNMP\Parameters\ValidCommunities"

    if($Community_Strings.Count -gt 0)
    {
        foreach($item in $Community_Strings)
        {
            if($item.Name -like "*public*" -or $item.Name -like "*private*")
            {
                $count++
            }
        }

        if($count -gt 0)
        {
            $result = "취약"
            $CV = "Community String 목록에 'public' 또는 'private'의 이름이 존재"
        }
        else
        {
            $result = "양호"
            $CV = "Community String 목록에 'public' 또는 'private'의 이름이 존재하지 않습니다"
        }

        foreach($item in $Community_Strings)
        {
            $tempSTR += $item
            $tempSTR += ','
        }
    }
    else
    {
        $result = "양호"
        $CV = "Community String을 사용하지 않습니다."
    }

    if($tempSTR.count -gt 0)
    {
        $tempSTR[-1] = ''
    }
}
else
{
    $result = "양호"
    $CV = "현재 서버에서 SNMP 서비스가 실행되고 있지 않습니다."
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

########### 62. SNMP Access control 설정 ###########

$index="62"
$title="SNMP Access control 설정"

$RV = "특정 호스트에게만 SNMP 패킷 받아들이기로 설정"
$importance = "중"

$flag = (Get-Service -Name *SNMP* | Where-Object {$_.Status -like "*Running*"}).count
if($flag -gt 0) {

    $setting = Get-RegistryValue "HKLM\SYSTEM\CurrentControlSet\services\SNMP\Parameters\PermittedManagers"
    $setting_count = ($setting.Value).count

    if ($setting_count -gt 1){
        $result = "양호"
        $CV = "특정 사용자에게 SNMP 패킷 받아들이기가 가능하도록 설정되어 있습니다."
    }
    else 
    {
        $result = "취약"
        $CV = "모든 사용자에게 SNMP 패킷 받아들이기가 가능하도록 설정되어 있습니다."
    }
}
else {
    $result = "양호"
    $CV = "SNMP가 구동되지 않은 상태입니다."
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

########### 63. DNS 서비스 구동 점검 ###########

$index="63"
$title="DNS 서비스 구동 점검"

$RV = "DNS 서비스를 사용하지 않거나 동적 업데이트를 사용하지 않음"
$importance = "중"

if((Get-Service *DNS*).count -gt 0)
{
    try {
        $flag = (Get-DnsServer).dynamicupdate

        if($flag.length -eq 0)
        {
            $result = "양호"
            $CV = "DNS 서버의 동적 업데이트 옵션이 비활성화 되어 있습니다."
        }
        else
        {
            $result = "취약"
            $CV = "DNS 서버의 동적 업데이트 옵션이 활성화 되어 있습니다."
        }
    }
    catch {
        $CV = "DNS 관련 서비스를 사용하고 있지 않습니다."
        $result = "양호"
    }
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

########### 64. HTTP/FTP/SNMP 배너 차단 ###########

$index="64"
$title="HTTP/FTP/SNMP 배너 차단"

$RV = "배너 정보가 보이지 않는 경우"
$importance = "하"

$flag = (Get-RegistryValue "HKLM\SYSTEM\CurrentControlSet\Services\HTTP" | Where-Object {$_.Name -like "*DisableServerHeader*"}).Value

$total_web_count = 0
$tempSTR = @()

# HTTP Header Option Read
if($flag -eq 1)
{
    $result = "양호"
}
else
{
    $result = "취약"
}

#FTP banner setting Read

for($X=0;$X -lt $FTP_Site_Name_list.count;$X++)
{
    $ftp_banner_option = Get-WebConfiguration //siteDefaults//. -PSPath $FTP_Site_Path_list[$X] | select-object suppressDefaultBanner

    if($ftp_banner_option -like "*False*")
    {
        $total_web_count++
        $tempSTR += $FTP_Site_Name_list[$X]
        $tempSTR += ','

    }
}

if($tempSTR.count -gt 0)
{
    $tempSTR[-1] = ''
}

if($result -eq "양호")
{
    if($total_web_count -gt 0)
    {
        $result = "취약"
        $CV = "HTTP 헤더 제거 옵션이 적용되어 있으며, 배너 설정을 하지 않은 FTP 사이트는 " + $tempSTR +"입니다."
    }
    else
    {
        $CV = "HTTP 헤더 제거 옵션이 적용되어 있으며, 모든 FTP 사이트가 배너 설정이 적용 되어 있습니다."
    }
}
else
{
    if($total_web_count -gt 0)
    {
        $result = "취약"
        $CV = "HTTP 헤더 제거 옵션이 적용되어 있지 않으며, 배너 설정을 하지 않은 FTP 사이트는 " + $tempSTR +"입니다."
    }
    else
    {
        $result = "취약"
        $CV = "HTTP 헤더 제거 옵션이 적용되어 있지 않으며, 모든 FTP 사이트가 배너 설정이 적용 되어 있습니다."
    }
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

########### 65. Telnet 보안 설정 ###########

$index="65"
$title="Telnet 보안 설정"

$RV = "Telnet 서비스를 사용하지 않을 때"
$importance = "중"

if((Get-Service -Name "*telnet*").count -gt 0)
{
    $result = "취약"
    $CV = "telnet 서비스를 사용하고 있습니다."
}
else
{
    $result = "양호"
    $CV = "telnet 서비스를 사용하지 않습니다."
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

########### 66. 불필요한 ODBC / OLE-DB 데이터 소스와 드라이브 제거 ###########

$index="66"
$title="불필요한 ODBC / OLE-DB 데이터 소스와 드라이브 제거"

$RV = "시스템 DSN 부분의 Data Source를 현재 사용하는 경우"
$importance = "중"
$tempSTR = @()

$odbc_list = (Get-OdbcDsn).Name

if($odbc_list.count -gt 0)
{
    $result = "취약"

    foreach($item in $odbc_list)
    {
        $tempSTR += $item
        $tempSTR += ','
    }

    if($tempSTR.count -gt 0)
    {
        $tempSTR[-1] = ''
    }

    $CV = "현재 사용중인 ODBC는 " + $tempSTR + " 입니다."
}
else
{
    $result = "양호"
    $CV = "해당 서버에서 ODBC를 사용하고 있지 않습니다."
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

########### 67. 원격 터미널 접속 타임아웃 설정 ###########

$index="67"
$title="원격 터미널 접속 타임아웃 설정"

$RV = "원격제어 시 Timeout 제어 설정을 적용한 경우"
$importance = "중"

# 레지스트리 경로 및 키 설정
$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
$regKeyIdleTime = "MaxIdleTime"

try {
    # 정책이 사용 상태인지 확인 (레지스트리 키가 존재하는지 체크)
    $sessionLimit = (Get-ItemProperty -Path $regPath -Name $regKeyIdleTime -ErrorAction SilentlyContinue).$regKeyIdleTime
        
    # 정책 사용 상태와 유휴 세션 제한 시간 확인
    if ($sessionLimit) { 
        # 유휴 세션 제한 시간이 30분 이상인지 확인 (밀리초 기준 1800000)
        if ($sessionLimit -ge 1800000) {
            $result = "양호"
            $CV = "유휴 세션 제한 시간이 30분 이상으로 설정됨"
        } else {
            $result = "취약"
            $CV = "유휴 세션 제한 시간이 30분 미만으로 설정됨"
        }
    } else {
        $result = "취약"
        $CV = "유휴 세션 제한 시간이 설정되지 않음"
    }
}
catch {
    $result = "수동"
    $CV = "정책 확인 중 오류 발생"
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

########### 68. 예약된 작업에 의심스러운 명령이 등록되어 있는지 점검 ###########

$index="68"
$title="원격 터미널 접속 타임아웃 설정"
$result = "수동"

$RV = "주기적인 예약 작업의 존재 여부를 주기적으로 점검하고 제거한 경우"
$CV = "예약된 작업 목록 중 불필요한 작업은 삭제하여 주세요."
$importance = "중"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

#############################################################################################################################