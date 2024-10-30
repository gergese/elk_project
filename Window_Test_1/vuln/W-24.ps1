###############################################

########### 24. NetBIOS 바인딩 서비스 구동 점검 ###########


$index = $checklist.check_list[23].code
$title = $checklist.check_list[23].title
$root_title = $checklist.check_list[23].root_title
$result = "수동"
$RV = "TCP/IP - NetBIOS 간의 바인딩 제거"
$importance = $checklist.check_list[23].importance

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

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title