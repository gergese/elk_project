########### 37. SAM 파일 접근 통제 설정 ###########

$index = $checklist.check_list[36].code
$title = $checklist.check_list[36].title
$root_title = $checklist.check_list[36].root_title

$RV = "SAM 파일 접근 권한에 Administrator , System 그룹만 모든 권한으로 설정되어 있는 경우"
$importance = $checklist.check_list[36].importance


$tempSTR = @()

$Access_sam = (Get-Permissions -Path "C:\Windows\System32\config\SAM").IdentityReference
$Count = 0

foreach ($Nameitem in $Access_sam) {
    $tempSTR += $Nameitem
    $tempSTR += ','

    if (!($Nameitem -like "*SYSTEM*" -or $Nameitem -like "*Administrator*")) {
        $Count++    
    }
}

if ($tempSTR.count -gt 0) {
    $tempSTR[-1] = ''
}

if ($Count -eq 0) {
    $result = "양호"
    $CV = "SAM 파일의 권한이 SYSTEM / Administrator 계정에만 부여되어 있습니다."
}
else {
    $result = "취약"
    $CV = "SAM 파일에 권한이 존재하는 그룹 / 사용자는 " + $tempSTR + " 입니다."
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title