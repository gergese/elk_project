###############################################

###### 57. 원격터미널 접속 가능한 사용자 그룹 제한 ######

$index = $checklist.check_list[56].code
$title = $checklist.check_list[56].title
$root_title = $checklist.check_list[56].root_title
$RV = "관리자가 아닌 별도의 원격접속 계정이 존재"
$importance = $checklist.check_list[56].importance
$CV = @()

# 원격 데스크톱 설정을 위한 레지스트리 경로
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server"

# 원격 데스크톱 연결 허용 여부 확인
$allowTsConnections = Get-ItemProperty -Path $regPath -Name "fDenyTSConnections"
if($allowTsConnections.fDenyTSConnections -eq 1) {
    $result = "양호"
    $CV = "원격 데스크톱 연결 허용 안 함"
}
else {

    $var =  (Get-LocalGroupMember -Group "Remote Desktop Users").length

    if($var -eq 0)
    {
        $result = "취약"
        $CV = "별도 계정 존재X. 별도 계정 생성 바람"
    }
    else
    {
        $tempStr = (Get-LocalGroupMember -Group "Remote Desktop Users").Name

        foreach($item in $tempStr)
        {
            $item = Out-String -InputObject $item
            $item = $item.Split('\')
            $Name = $item[-1].Trim()

            $CV += $Name
            $CV += ','
        }

        if($CV.count -gt 0)
        {
            $CV[-1] = ''
        }

        $result = "수동"
        $CV = $CV.Trim()
        $CV += "원격 접속 허용 계정 확인 필요"
    }
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title