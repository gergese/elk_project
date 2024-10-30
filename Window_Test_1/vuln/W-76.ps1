###############################################

########### 76. 사용자별 홈 디렉토리 권한 설정 ###########

$index = $checklist.check_list[75].code
$title = $checklist.check_list[75].title
$root_title = $checklist.check_list[75].root_title

$RV = "홈 디렉토리에 Everyone 권한이 없는 경우"
$importance = $checklist.check_list[75].importance

$tempSTR = @()
$total_count = 0

$User_List = (Get-Localuser).Name
$User_Home_DIR = @()

foreach ($user_item in $User_List) {
    $User_Home_DIR += 'C:\Users\' + $user_item
}

for ($X = 0; $X -lt $User_Home_DIR.Count; $X++) {
    $flag = Test-Path -Path $User_Home_DIR[$X]

    if ($flag) {
        $Everyone_Access_count = (Get-Permissions -Path $User_Home_DIR[$X] | Where-Object { $_.IdentityReference -like "*Everyone*" }).Count
        if ($Everyone_Access_count -gt 0) {
            $tempSTR += $User_List[$X]
            $tempSTR += ','

            $total_count++
        }
    }
}

if ($tempSTR.count -gt 0) {
    $tempSTR[-1] = ''
}

if ($total_count -gt 0) {
    $result = "취약"
    $CV = $tempSTR + "사용자 홈 디렉토리에서 Everyone 권한 존재"
}
else {
    $result = "양호"
    $CV = "홈 디렉토리에 Everyone 권한을 가진 사용자는 존재X"
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title