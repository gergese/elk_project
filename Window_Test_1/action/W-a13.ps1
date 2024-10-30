###############################################

########### 13. IIS 상위 디렉토리 접근 금지 ###########

$index = $checklist.check_list[12].code
$title = $checklist.check_list[12].title
$root_title = $checklist.check_list[12].root_title
$importance = $checklist.check_list[11].importance

$Site_List = Get-ChildItem IIS:\Sites | select -expand Name

$PSPath = 'MACHINE/WEBROOT/APPHOST'
$Filter = 'system.webServer/asp'
$Name = 'enableParentPaths'

foreach($Location in $Site_List)
{
    Set-WebConfigurationProperty -PSPath $PSPath -Location $Location -Filter $Filter -Name $Name -Value "False"
}

$CV = "상위 디렉토리 접근 기능 False로 설정"
$result = "양호"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title