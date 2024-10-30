###############################################

########### 11. 디렉토리 리스팅 제거 ###########

$index = $checklist.check_list[10].code
$title = $checklist.check_list[10].title
$root_title = $checklist.check_list[10].root_title
$importance = $checklist.check_list[10].importance

$Site_List = Get-ChildItem IIS:\Sites | select -expand Name

$PSPath = 'MACHINE/WEBROOT/APPHOST'
$Filter = 'system.webServer/directoryBrowse'
$Name = 'enabled'

foreach($Location in $Site_List)
{
    # 디렉터리 검색 설정 비활성화
    Set-WebConfigurationProperty -PSPath $PSPath$Location -Filter $Filter -Name $Name -Value $false
}

$CV = "사이트의 디렉터리 검색이 사용 안 함으로 설정되었습니다."
$result = "양호"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title