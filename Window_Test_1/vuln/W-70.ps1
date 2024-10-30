###############################################

########### 70. 이벤트 로그 관리 설정 ###########

$index = $checklist.check_list[69].code
$title = $checklist.check_list[69].title
$root_title = $checklist.check_list[69].root_title

$RV = "최대 로그 크기 10,240KB 이상 & '90일 이후 이벤트 덮어 씀' 설정" 
$importance = $checklist.check_list[69].importance
$CV = ""

$tempSTR = @(0,0,0)
$tempSTR_option = @(0,0,0)

# 응용 프로그램 로그 설정
$setting_option = (Get-RegistryValue "HKLM\SYSTEM\CurrentControlSet\Services\EventLog\Application" | Where-Object {$_.Name -eq "Retention"}).Value
$max_log_size = (Get-RegistryValue "HKLM\SYSTEM\CurrentControlSet\Services\EventLog\Application" | Where-Object {$_.Name -eq "MaxSize"}).Value

if($setting_option -ge 0 -and ($max_log_size / 1024) -ge 10240)
{
    $tempSTR[0] = ($max_log_size / 1024).toString() + "KB"
    $tempSTR_option[0] = 1
}
else
{
    $tempSTR[0] = ($max_log_size / 1024).toString() + "KB"
    $tempSTR_option[0] = 0
}

# 보안 관련 로그 설정
$setting_option = (Get-RegistryValue "HKLM\SYSTEM\CurrentControlSet\Services\EventLog\Security" | Where-Object {$_.Name -eq "Retention"}).Value
$max_log_size = (Get-RegistryValue "HKLM\SYSTEM\CurrentControlSet\Services\EventLog\Security" | Where-Object {$_.Name -eq "MaxSize"}).Value

if($setting_option -ge 0 -and ($max_log_size / 1024) -ge 10240)
{
    $tempSTR[1] = ($max_log_size / 1024).toString() + "KB"
    $tempSTR_option[1] = 1
}
else
{
    $tempSTR[1] = ($max_log_size / 1024).toString() + "KB"
    $tempSTR_option[1] = 0
}

# 시스템 관련 로그 설정
$setting_option = (Get-RegistryValue "HKLM\SYSTEM\CurrentControlSet\Services\EventLog\System" | Where-Object {$_.Name -eq "Retention"}).Value
$max_log_size = (Get-RegistryValue "HKLM\SYSTEM\CurrentControlSet\Services\EventLog\System" | Where-Object {$_.Name -eq "MaxSize"}).Value

if($setting_option -ge 0 -and ($max_log_size / 1024) -ge 10240)
{
    $tempSTR[2] = ($max_log_size / 1024).toString() + "KB"
    $tempSTR_option[2] = 1
}
else
{
    $tempSTR[2] = ($max_log_size / 1024).toString() + "KB"
    $tempSTR_option[2] = 0
}

if (($tempSTR_option[0] -eq 1) -and ($tempSTR_option[1] -eq 1) -and ($tempSTR_option[2] -eq 1))
{
    $result = "양호"
    $CV = "오래된 이벤트 로그 우선 삭제O / 크기는 10,240KB 이상 입니다."   

}
else
{
    $result = "취약"
    if($tempSTR_option[0] -eq 0) {
        $CV += "응용 프로그램 관련 로그는 오래된 이벤트 우선 삭제X / 크기는 " + $tempSTR[0] + " 입니다." 
    }
    if($tempSTR_option[1] -eq 0) {
        $CV += "응용 프로그램 관련 로그는 오래된 이벤트 우선 삭제X / 크기는 " + $tempSTR[1] + " 입니다." 
    }
    if($tempSTR_option[2] -eq 0) {
        $CV += "응용 프로그램 관련 로그는 오래된 이벤트 우선 삭제X / 크기는 " + $tempSTR[2] + " 입니다." 
    }
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title