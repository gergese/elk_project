###############################################

########### 24. NetBIOS 바인딩 서비스 구동 점검 ###########


$index = $checklist.check_list[23].code
$title = $checklist.check_list[23].title
$root_title = $checklist.check_list[23].root_title
$importance = $checklist.check_list[23].importance

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
$result = "양호"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title