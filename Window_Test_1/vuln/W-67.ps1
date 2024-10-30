###############################################

########### 67. 원격 터미널 접속 타임아웃 설정 ###########

$index = $checklist.check_list[66].code
$title = $checklist.check_list[66].title
$root_title = $checklist.check_list[66].root_title

$RV = "원격제어 시 Timeout 제어 설정을 적용한 경우"
$importance = $checklist.check_list[66].importance

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

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title