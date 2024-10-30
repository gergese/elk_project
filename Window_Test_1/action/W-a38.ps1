###############################################

########### 38. 화면보호기 설정 ###########

$index = $checklist.check_list[37].code
$title = $checklist.check_list[37].title
$root_title = $checklist.check_list[37].root_title
$importance = $checklist.check_list[37].importance

# 레지스트리 경로 설정
$regPath = "HKCU\Control Panel\Desktop"

# Timeout 설정 (10분 = 600초)
$TimeoutValue = 600
Set-ItemProperty -Path $regPath -Name "ScreenSaveTimeOut" -Value $TimeoutValue

# Secure 설정 (1로 설정)
$SecureValue = 1
Set-ItemProperty -Path $regPath -Name "ScreenSaveActive" -Value $SecureValue

# Lock 설정 (1로 설정)
$LockValue = 1
Set-ItemProperty -Path $regPath -Name "ScreenSaverIsSecure" -Value $LockValue

$CV = "화면 보호기 설정. 재부팅 필요"
$result = "양호"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title