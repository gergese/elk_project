###############################################

###### 56. 콘솔 로그온 시 로컬 계정에서 빈 암호 사용 제한 ######

$index = $checklist.check_list[55].code
$title = $checklist.check_list[55].title
$root_title = $checklist.check_list[55].root_title
$importance = $checklist.check_list[55].importance

$RegPath = "HKLM:SYSTEM\CurrentControlSet\Control\Lsa"
$Name = "LimitBlankPasswordUse"
    
$var = Get-ItemPropertyValue -Path $RegPath -Name $Name
    
# 현재 값 읽기
$currentValue = Get-ItemPropertyValue -Path $RegPath -Name $Name
    
# 값을 0으로 변경
Set-ItemProperty -Path $RegPath -Name $Name -Value 1
    
$CV = "LimitBlankPasswordUse 1로 설정"
$result = "양호"
    
Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title