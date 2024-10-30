###############################################

########### 67. 원격 터미널 접속 타임아웃 설정 ###########

$index = $checklist.check_list[66].code
$title = $checklist.check_list[66].title
$root_title = $checklist.check_list[66].root_title
$importance = $checklist.check_list[66].importance

# 레지스트리 경로 및 키 설정
$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
$regKeyIdleTime = "MaxIdleTime"
$idleTimeValue = 1800000  # 30분을 초로 설정

# 레지스트리 경로가 존재하는지 확인
if (-not (Test-Path $regPath)) {
    # 레지스트리 경로가 없으면 생성
    New-Item -Path $regPath -Force
}

# MaxIdleTime 값을 30분으로 설정
Set-ItemProperty -Path $regPath -Name $regKeyIdleTime -Value $idleTimeValue

# 결과 출력
$currentValue = Get-ItemProperty -Path $regPath -Name $regKeyIdleTime

$CV = "MaxIdleTime 30분으로 설정"
$result = "양호"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title