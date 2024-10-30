###############################################

########### 42. SAM 계정과 공유의 익명 열거 허용 안 함 ###########

$index = $checklist.check_list[41].code
$title = $checklist.check_list[41].title
$root_title = $checklist.check_list[41].root_title

$RV = "해당 정책을 사용하지 않을 경우"
$importance = $checklist.check_list[41].importance

$flag = (Get-RegistryValue "HKLM\SYSTEM\CurrentControlSet\Control\Lsa\" | Where-Object { $_.Name -eq "restrictanonymous" }).Value
$flag2 = (Get-RegistryValue "HKLM\SYSTEM\CurrentControlSet\Control\Lsa\" | Where-Object { $_.Name -eq "restrictanonymoussam" }).Value

if ($flag -eq 1 -and $flag2 -eq 1) {
    $result = "양호"
    $CV = "'SAM 계정과 공유의 익명 열거 허용 안 함' 을 사용하는 중입니다." 
}
else {
    $result = "취약"
    $CV = "'SAM 계정과 공유의 익명 열거 허용 안 함' 을 사용하지 않습니다."
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title