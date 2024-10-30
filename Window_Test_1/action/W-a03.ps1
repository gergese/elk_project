###############################################

############ 3. 불필요한 계정 제거 ############

$index = $checklist.check_list[2].code
$title = $checklist.check_list[2].title
$root_title = $checklist.check_list[2].root_title
$result = "수동"
$importance = $checklist.check_list[2].importance
$CV = "활성화된 계정들 중 불필요한 계정은 삭제하여 주세요."
$account_list = Get-LocalUser | Where-Object { $_.Enabled -eq $true } | Select-Object -ExpandProperty Name

$CV += "활성화된 계정 목록 : $account_list"
Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title