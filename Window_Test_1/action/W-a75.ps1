###############################################

########### 75. 경고 메세지 설정 ###########

$index = $checklist.check_list[74].code
$title = $checklist.check_list[74].title
$root_title = $checklist.check_list[74].root_title
$importance = $checklist.check_list[74].importance

$tempSTR = @("로그인 경고 제목이 설정되었습니다.", "로그인 경고 내용이 설정되었습니다.")

# 양호한 상태로 설정
$flag_title = "보안 경고"  # 경고 메세지 제목 예시
$flag_text = "본 시스템에 접근하기 전에 인증이 필요합니다. 불법 접근 시 법적 조치가 취해질 수 있습니다"   # 경고 메세지 내용 예시

# 로그인 경고 제목과 내용을 레지스트리에 설정
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "legalnoticecaption" -Value $flag_title
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "legalnoticetext" -Value $flag_text

# 양호 상태 설정
$result = "양호"
$tempSTR[0] = "설정된 로그인 경고 제목은 '" + $flag_title + "' 입니다."
$tempSTR[1] = "설정된 로그인 경고 내용은 '" + $flag_text + "' 입니다."

$CV = $tempSTR[0] + " " + $tempSTR[1]

# 결과를 데이터에 추가
Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title