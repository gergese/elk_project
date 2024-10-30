###############################################

############# 2. Guest 계정 상태 ##############

$index = $checklist.check_list[1].code
$title = $checklist.check_list[1].title
$root_title = $checklist.check_list[1].root_title
$importance = $checklist.check_list[1].importance

# Guest 계정의 활성화 여부 확인
$var = Get-LocalUser -Name Guest | Select-Object -ExpandProperty Enabled

if ($var -eq $true) {
    # Guest 계정이 활성화 상태이면 비활성화
    Disable-LocalUser -Name Guest
    $CV = "Guest 계정 비활성화"
    $result = "양호"
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title