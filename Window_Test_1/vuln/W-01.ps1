$root_title = $checklist.check_list[0].root_title
$index = $checklist.check_list[0].code
$title = $checklist.check_list[0].title
$importance = $checklist.check_list[0].importance
try{
    $Active_DIR_Service = Get-ADDefaultDomainPasswordPolicy
}
catch
{
    $Active_DIR_Service = 0
}

###### 1. Administrator 계정 이름 바꾸기 ######   

try {
    $adminAccount = Get-LocalUser -Name "Administrator"
}
catch {
    Write-Warning "Administrator 계정을 찾을 수 없습니다."
    $adminAccount = $null
}

if ($adminAccount)
{
    $result = "취약"
    $CV = "Administrator, Default 계정 이름 변경 필요"
}
else
{
    $result = "양호"
    
    $f1 = (Get-LocalGroupMember -Name "Administrators").Name
    $f1 = $f1 | Out-String
    $f1 = $f1.Split("\")
    $CV = $f1[-1]
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title
