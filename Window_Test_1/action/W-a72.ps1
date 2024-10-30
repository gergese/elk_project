###############################################

########### 72. DoS 공격 방어 레지스트리 설정 ###########

$index = $checklist.check_list[71].code
$title = $checklist.check_list[71].title
$root_title = $checklist.check_list[71].root_title

$importance = $checklist.check_list[71].importance

# 레지스트리 경로 설정
$regPath = "HKLM:\System\CurrentControlSet\Services\Tcpip\Parameters"

# 레지스트리 값 설정 함수
function Set-RegistryValue {
    param (
        [string]$Path,
        [string]$Name,
        [int]$Value
    )

    $currentValue = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
    if ($currentValue) {
        # 값이 존재하면 해당 값으로 설정
        Set-ItemProperty -Path $Path -Name $Name -Value $Value
    } else {
        # 값이 없으면 새로 추가
        New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType DWord
    }
}

# 각각의 값을 설정
Set-RegistryValue -Path $regPath -Name "SynAttackProtect" -Value 1
Set-RegistryValue -Path $regPath -Name "EnableDeadGWDetect" -Value 0
Set-RegistryValue -Path $regPath -Name "KeepAliveTime" -Value 300000
Set-RegistryValue -Path $regPath -Name "NoNameReleaseOnDemand" -Value 1

$CV = "SynAttackProtect 값 1, EnableDeadGWDetect 값 0, KeepAliveTime 값 300000, NoNameReleaseOnDemand 값 1로 설정"
$result = "양호"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title