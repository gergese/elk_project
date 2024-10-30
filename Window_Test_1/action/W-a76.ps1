###############################################

########### 76. 사용자별 홈 디렉토리 권한 설정 ###########

$index = $checklist.check_list[75].code
$title = $checklist.check_list[75].title
$root_title = $checklist.check_list[75].root_title
$importance = $checklist.check_list[75].importance

$tempSTR = @()
$total_count = 0

# 모든 로컬 사용자 목록을 가져옵니다.
$User_List = (Get-Localuser).Name
$User_Home_DIR = @()

# 각 사용자의 홈 디렉토리를 배열에 추가
foreach ($user_item in $User_List) {
    $User_Home_DIR += 'C:\Users\' + $user_item
}

# 각 사용자 홈 디렉토리에서 Everyone 권한이 있는지 확인하고 제거
for ($X = 0; $X -lt $User_Home_DIR.Count; $X++) {
    $flag = Test-Path -Path $User_Home_DIR[$X]

    if ($flag) {
        # 'Everyone' 그룹의 권한을 확인
        $Everyone_Access_count = (Get-Permissions -Path $User_Home_DIR[$X] | Where-Object { $_.IdentityReference -like "*Everyone*" }).Count
        if ($Everyone_Access_count -gt 0) {
            # 'Everyone' 그룹 권한이 있는 경우 제거
            Remove-Permissions -Path $User_Home_DIR[$X] -IdentityReference "Everyone"
            $tempSTR += $User_List[$X] + " 사용자의 홈 디렉토리에서 Everyone 권한 제거 완료"
            $total_count++
        }
    }
}

if ($total_count -gt 0) {
    $result = "양호"
    $CV = $tempSTR + "사용자 홈 디렉토리에서 Everyone 권한이 제거되었습니다."
}
else {
    $result = "양호"
    $CV = "홈 디렉토리에 Everyone 권한을 가진 사용자는 존재하지 않습니다."
}

# 결과 데이터를 저장
Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title