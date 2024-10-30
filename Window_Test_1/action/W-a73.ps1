###############################################

########### 73. 사용자가 프린터 드라이버를 설치할 수 없게 함 ###########

$index = $checklist.check_list[72].code
$title = $checklist.check_list[72].title
$root_title = $checklist.check_list[72].root_title

$importance = $checklist.check_list[72].importance

$flag = (Get-RegistryValue "HKLM\SYSTEM\CurrentControlSet\Control\Print\Providers\LanMan Print Services\Servers" | Where-Object { $_.Name -eq "AddPrinterDrivers" }).Value
    
# 레지스트리 경로 설정
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Print\Providers\LanMan Print Services\Servers"
$keyName = "AddPrinterDrivers"

# 현재 값 확인
$currentValue = Get-ItemProperty -Path $regPath -Name $keyName -ErrorAction SilentlyContinue

if ($currentValue) {
    # 값이 존재하면 1로 설정
    Set-ItemProperty -Path $regPath -Name $keyName -Value 1
}

$CV = "AddPrinterDrivers 값 1로 설정"
$result = "양호"
Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title