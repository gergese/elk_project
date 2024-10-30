###############################################

###### 8. 하드디스크 기본 공유 제거 ######

$index = $checklist.check_list[7].code
$title = $checklist.check_list[7].title
$root_title = $checklist.check_list[7].root_title
$importance = $checklist.check_list[7].importance

# IPC$를 제외한 기본 공유 폴더가 존재하는지 확인
$DefaultSmbInfo = @(Get-SmbShare | Where-Object { $_.Name -ne "IPC$" } | Where-Object { $_.Name -like "*$" })
$var = $DefaultSmbInfo.Length
$RegPath = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters"
$Name = "AutoShareServer"

try {
    $REGvar = Get-ItemPropertyValue -Path $RegPath -Name $Name
}
catch {
}

if ($var -gt 0) {
    $result = "취약"
    $CV = "기본 공유 폴더가 존재하며, "
}
else {
    $result = "양호"
    $CV = "기본 공유 폴더가 존재하지 않으며, "
}

if ($REGvar -eq 0) {
    $CV += "AutoShareServer 값은 0"
}
elseif ($REGvar -eq 1) {
    $result = "취약"
    $CV += "AutoShareServer 값은 1"
}
else {
    $result = "취약"
    $CV += "AutoShareServer 값 설정X"
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title