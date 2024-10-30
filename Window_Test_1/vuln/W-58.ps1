###############################################

########### 58. 터미널 서비스 암호화 수준 설정 ###########

$index = $checklist.check_list[57].code
$title = $checklist.check_list[57].title
$root_title = $checklist.check_list[57].root_title
$importance = $checklist.check_list[57].importance
$RV = "터미널 서비스 사용X / 암호화 수준 '클라이언트와 호환 가능(중간)' 이상으로 설정"

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

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title