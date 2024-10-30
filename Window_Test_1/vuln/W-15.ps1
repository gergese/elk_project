###############################################

########### 15. 웹 프로세스 권한 제한 ###########

$index = $checklist.check_list[14].code
$title = $checklist.check_list[14].title
$root_title = $checklist.check_list[14].root_title
$result = "수동"
$RV = "웹 서비스 운영에 필요한 최소 권한으로 설정"
$importance = $checklist.check_list[14].importance

# 애플리케이션 풀 아이덴티티와 ID를 가져오는 함수 정의
function Get-AppPoolDetails {
    param (
        [string]$Site_Name
    )

    # 애플리케이션 풀 이름 가져오기
    $AppPoolName = Get-WebConfigurationProperty -PSPath "MACHINE/WEBROOT/APPHOST" -Filter "system.applicationHost/sites/site[@name='$Site_Name']/application[@path='/']" -Name "applicationPool" | Select-Object -ExpandProperty Value

    # 애플리케이션 풀 정보 가져오기 (Get-IISAppPool 사용)
    $AppPool = Get-IISAppPool | Where-Object { $_.Name -eq $AppPoolName }

    if ($AppPool) {
        $AppPoolIdentity = $AppPool.processModel.identityType
        $AppPoolID = $AppPool.id

        return @{
            Identity = $AppPoolIdentity
            ID       = $AppPoolID
        }
    }
    else {
        Write-Host "Application Pool '$AppPoolName' not found."
        return $null
    }
}

# 애플리케이션 풀 아이덴티티와 ID를 가져와서 출력
foreach ($Site_Name in $Site_Name_list) {
    $AppPoolDetails = Get-AppPoolDetails -Site_Name $Site_Name
    if ($AppPoolDetails.Identity -ne "ApplicationPoolIdentity") {
        $result = "취약"
        $CV = "ApplicationPoolIdentity가 적용되지 않은 사이트 존재"
    }
    else {
        $CV = "웹 서비스 운영에 필요한 최소 권한 확인 필요"
    }
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title