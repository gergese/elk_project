#############################################################################################################


$index=0
$root_title="로그 관리"
$title=0
$result=0

#################################################### < 4 . 로그 관리 > ####################################################
#############################################################################################################################

########### 34. 로그의 정기적 검토 및 보고 ###########

$index="34"
$title="로그의 정기적 검토 및 보고"
$result = "수동"

$RV = "로그 , 응용 프로그램 및 시스템 로그 기록에 대해 정기적으로 검토 분석등이 이루어지는 경우"
$importance = "상"
$CV = "수동 확인"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

########### 35. 원격으로 액세스 할 수 있는 레지스트리 경로 ###########

$index="35"
$title="원격으로 액세스 할 수 있는 레지스트리 경로"

$RV = "RemoteRegistry Service를 사용하지 않는 경우"
$importance = "상"

$Service_Status = (Get-Service -Name "RemoteRegistry").Status

if($Service_Status -gt "Running")
{
    $result = "양호"
    $CV = "원격 레지스트리 서비스를 사용하고 있지 않습니다."
}
else
{
    $result = "취약"
    $CV = "원격 레지스트리 서비스를 사용하고 있습니다."      
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

########### 70. 이벤트 로그 관리 설정 ###########

$index="70"
$title="이벤트 로그 관리 설정"

$RV = "최대 로그 크기 10,240KB 이상 & '90일 이후 이벤트 덮어 씀' 설정" 
$importance = "하"
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

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

########### 71. 원격에서 이벤트 로그 파일 접근 차단 ###########

$index="71"
$title="원격에서 이벤트 로그 파일 접근 차단"

$RV = "로그 디렉토리의 접근 권한에 Everyone 권한이 없는 경우"
$importance = "중"

$Everyone_Access = (Get-Permissions -Path "C:\Windows\System32\config" | Where-Object {$_.IdentityReference -like "*Everyone*"}).Count
$Everyone_Access2 = (Get-Permissions -Path "C:\Windows\System32\LogFiles" | Where-Object {$_.IdentityReference -like "*Everyone*"}).Count      

if($Everyone_Access -eq 0 -and $Everyone_Access2 -eq 0)
{
    $result = "양호"
    $CV = "시스템 로그 디렉토리와 IIS 로그 디렉토리에 Everyone 권한이 존재하지 않습니다."
}
else
{
    if($Everyone_Access -gt 0 -and $Everyone_Access2 -gt 0)
    {
        $CV = "시스템 로그 , IIS 로그 디렉토리에 Everyone 권한이 존재합니다."
        $result = "취약"
    }
    elseif($Everyone_Access -gt 0)
    {
        $result = "취약"
        $CV = "시스템 로그에 Everyone 권한이 존재합니다."
    }
    elseif($Everyone_Access2 -gt 0)
    {
        $result = "취약"
        $CV = "IIS 로그 디렉토리에 Everyone 권한이 존재합니다."
    }
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV
 
###############################################

#############################################################################################################################