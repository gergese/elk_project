# 문서화를 위한 결과 저장 변수
$index = 0
$root_title = "계정 관리"
$title = 0
$result = 0

#Recommanded Value
$RV = 0

#Current value
$CV = 0

#비고란
$importance = 0

############################################# < 1 . 계정 관리 취약점 항목 점검> #############################################

#############################################################################################################################

$title = "계정 관리 취약점 항목 점검"

try {
    $Active_DIR_Service = Get-ADDefaultDomainPasswordPolicy
}
catch {
    $Active_DIR_Service = 0
}

###### 1. Administrator 계정 이름 바꾸기 ######   

$index = "01"
$RV = "Administrator가 아닌 다른 값"
$importance = "상"
$title = "Administrator 계정 이름 바꾸기"

if($trueIndexes -contains $index) {
    # 변경할 계정 이름 설정
    $oldAdminName = "Administrator"
    $newAdminName = "KISIA"  # 새 계정 이름 설정

    # 관리자 계정이 존재하는지 확인
    $adminAccount = Get-LocalUser -Name $oldAdminName

    if ($adminAccount) {
        # 계정 이름 변경
        Rename-LocalUser -Name $oldAdminName -NewName $newAdminName
        $CV = "관리자 계정 이름이 '$oldAdminName'에서 '$newAdminName'으로 변경되었습니다."
        $result = "양호"
        Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV
    }
}


###############################################

############# 2. Guest 계정 상태 ##############

$index = "02"
$title = "Guest 계정 상태"

$RV = "Guest 계정 비활성화"
$importance = "상"

if($trueIndexes -contains $index) {
    # Guest 계정의 활성화 여부 확인
    $var = Get-LocalUser -Name Guest | Select-Object -ExpandProperty Enabled

    if ($var -eq $true) {
        # Guest 계정이 활성화 상태이면 비활성화
        Disable-LocalUser -Name Guest
        $CV = "Guest 계정 비활성화"
        $result = "양호"
        Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV
    }
}

###############################################

########### 4. 계정 잠금 임계값 설정 ###########

$index = "04"
$title = "계정 잠금 임계값 설정"

$RV = "5이하"
$importance = "상"

if($trueIndexes -contains $index) {
    # ClearTextPassword 항목 찾기
    $tempStr = Get-Content $securityTemplatePath | Select-String "LockoutBadCount"

    $tempStr = $tempStr -replace "LockoutBadCount\s*=\s*\d+", "LockoutBadCount = 5"

    # 파일 내용 전체를 가져와서 수정된 내용을 반영합니다.
    $fileContent = Get-Content $securityTemplatePath

    # ClearTextPassword 라인을 수정합니다.
    $fileContent = $fileContent -replace "LockoutBadCount\s*=\s*\d+", $tempStr

    # 수정된 내용을 파일에 다시 저장
    Set-Content -Path $securityTemplatePath -Value $fileContent

    # 보안 템플릿 임포트
    secedit /configure /db $databasePath /cfg $securityTemplatePath

    SecEdit /export /cfg $securityTemplatePath

    $CV = "LockoutBadCount 5로 변경"
    $result = "양호"
    Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV

}

###############################################

###### 5. 해독 가능한 암호화를 사용하여 암호 저장 해제 ######

$index = "05"
$title = "해독 가능한 암호화를 사용하여 암호 저장 해제"

$RV = "사용 안 함"
$importance = "상"

if($trueIndexes -contains $index) {
    $tempStr = Get-Content $securityTemplatePath | Select-String "ClearTextPassword"
    # 값 가져오기
    $tempStr = $tempStr -replace "ClearTextPassword\s*=\s*\d+", "ClearTextPassword = 5"
    
    # 파일 내용 전체를 가져와서 수정된 내용을 반영합니다.
    $fileContent = Get-Content $securityTemplatePath
    
    # ClearTextPassword 라인을 수정합니다.
    $fileContent = $fileContent -replace "ClearTextPassword\s*=\s*\d+", $tempStr
    
    # 수정된 내용을 파일에 다시 씁니다.
    Set-Content -Path $securityTemplatePath -Value $fileContent
    
    $CV = "해독 가능한 암호화를 사용하여 암호 저장 '사용 안 함' 설정"
    $result = "양호"
    Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV
    
}

###############################################

###### 46. Everyone 사용권한을 익명사용자에 적용 해제 ######

$index = "46"
$title = "Everyone 사용권한을 익명사용자에 적용 해제"

$RV = "사용 안 함"
$importance = "중"

if($trueIndexes -contains $index) {
    # 레지스트리 경로와 이름 정의
    $RegPath = "HKLM:SYSTEM\CurrentControlSet\Control\Lsa"
    $Name = "EveryoneIncludesAnonymous"

    # 현재 값 읽기
    # $currentValue = Get-ItemPropertyValue -Path $RegPath -Name $Name

    # 값을 0으로 변경
    Set-ItemProperty -Path $RegPath -Name $Name -Value 0

    # 변경 후 확인
    $CV = "Everyone 사용 권한을 익명 사용자에게 적용 정책 '사용 안 함' 설정"
    $result = "양호"
    Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV

}

###############################################

########### 47. 계정 잠금 기간 설정 ###########

$index = "47"
$title = "계정 잠금 기간 설정"

$RV = "60(분)이상"
$importance = "중"

if($trueIndexes -contains $index) {
    # ClearTextPassword 항목 찾기
    $tempStr = Get-Content $securityTemplatePath | Select-String "LockoutDuration"

    $tempStr = $tempStr -replace "LockoutDuration\s*=\s*\d+", "LockoutDuration = 60"

    # 파일 내용 전체를 가져와서 수정된 내용을 반영합니다.
    $fileContent = Get-Content $securityTemplatePath

    # ClearTextPassword 라인을 수정합니다.
    $fileContent = $fileContent -replace "LockoutDuration\s*=\s*\d+", $tempStr

    # 수정된 내용을 파일에 다시 저장
    Set-Content -Path $securityTemplatePath -Value $fileContent

    $CV = "LockoutDuration 60으로 변경"
    $result = "양호"
    Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV

}

###############################################

########### 48. 패스워드 복잡성 설정 ##########

$index = "48"
$title = "패스워드 복잡성 설정"

$RV = "사용"
$importance = "중"

if($trueIndexes -contains $index) {
    # ClearTextPassword 항목 찾기
    $tempStr = Get-Content $securityTemplatePath | Select-String "PasswordComplexity"

    $tempStr = $tempStr -replace "PasswordComplexity\s*=\s*\d+", "PasswordComplexity = 1"

    # 파일 내용 전체를 가져와서 수정된 내용을 반영합니다.
    $fileContent = Get-Content $securityTemplatePath

    # ClearTextPassword 라인을 수정합니다.
    $fileContent = $fileContent -replace "PasswordComplexity\s*=\s*\d+", $tempStr

    # 수정된 내용을 파일에 다시 저장
    Set-Content -Path $securityTemplatePath -Value $fileContent

    $CV = "PasswordComplexity 사용 설정"
    $result = "양호"
    Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV

}

###############################################

######## 49. 패스워드 최소 암호 길이 ##########

$index = "49"
$title = "패스워드 최소 암호 길이"

$RV = "8(자)이상"
$importance = "중"

if($trueIndexes -contains $index) {
    # ClearTextPassword 항목 찾기
    $tempStr = Get-Content $securityTemplatePath | Select-String "MinimumPasswordLength"

    $tempStr = $tempStr -replace "MinimumPasswordLength\s*=\s*\d+", "MinimumPasswordLength = 8"

    # 파일 내용 전체를 가져와서 수정된 내용을 반영합니다.
    $fileContent = Get-Content $securityTemplatePath

    # ClearTextPassword 라인을 수정합니다.
    $fileContent = $fileContent -replace "MinimumPasswordLength\s*=\s*\d+", $tempStr

    # 수정된 내용을 파일에 다시 저장
    Set-Content -Path $securityTemplatePath -Value $fileContent

    $CV = "MinimumPasswordLength 8자로 설정"
    $result = "양호"
    Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV

}

###############################################

######### 50. 패스워드 최대 사용 기간 #########

$index = "50"
$title = "패스워드 최대 사용 기간"

$RV = "90(일)이하"
$importance = "중"

if($trueIndexes -contains $index) {
    # 파일 경로 정의
    $securityTemplatePath = ".\user_rights.inf"

    # 파일 내용 전체를 가져옵니다.
    $fileContent = Get-Content $securityTemplatePath

    # 첫 번째 'MaximumPasswordAge' 항목 찾기
    $firstMatch = $fileContent | Select-String -Pattern "MaximumPasswordAge" | Select-Object -First 1

    # 첫 번째 'MaximumPasswordAge'의 인덱스 찾기
    $firstMatchIndex = $fileContent.IndexOf($firstMatch.Line)

    # 첫 번째 'MaximumPasswordAge' 값을 원하는 값으로 변경 (예: 90일로 설정)
    $fileContent[$firstMatchIndex] = $fileContent[$firstMatchIndex] -replace "MaximumPasswordAge\s*=\s*\d+", "MaximumPasswordAge = 90"

    # 수정된 내용을 파일에 다시 저장합니다.
    Set-Content -Path $securityTemplatePath -Value $fileContent

    $CV = "첫 번째 MaximumPasswordAge 값이 90으로 변경되었습니다."
    $result = "양호"
    Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV

    # 보안 템플릿 임포트
    secedit /configure /db $databasePath /cfg $securityTemplatePath
    SecEdit /export /cfg $securityTemplatePath

}

###############################################

######### 51. 패스워드 최소 사용 기간 #########

$index = "51"
$title = "패스워드 최소 사용 기간"

$RV = "0보다 큰 값"
$importance = "중"

if($trueIndexes -contains $index) {
    # MinimumPasswordAge 항목 찾기
    $tempStr = Get-Content $securityTemplatePath | Select-String "MinimumPasswordAge"

    $tempStr = $tempStr -replace "MinimumPasswordAge\s*=\s*\d+", "MinimumPasswordAge = 1"

    # 파일 내용 전체를 가져와서 수정된 내용을 반영합니다.
    $fileContent = Get-Content $securityTemplatePath

    # MinimumPasswordAge 라인을 수정합니다.
    $fileContent = $fileContent -replace "MinimumPasswordAge\s*=\s*\d+", $tempStr

    # 수정된 내용을 파일에 다시 저장
    Set-Content -Path $securityTemplatePath -Value $fileContent

    $CV = "MinimumPasswordAge 1일로 설정"
    $result = "양호"
    Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV

}

###############################################

###### 52. 마지막 사용자 이름 표시 안 함 ######

$index = "52"
$title = "마지막 사용자 이름 표시 안 함"

$RV = "사용"
$importance = "중"

if($trueIndexes -contains $index) {
    # 레지스트리 경로와 이름 정의
    $RegPath = "HKLM:Software\Microsoft\Windows\CurrentVersion\Policies\System"
    $Name = "dontdisplaylastusername"

    # 현재 값 읽기
    # $currentValue = Get-ItemPropertyValue -Path $RegPath -Name $Name

    # 값을 0으로 변경
    Set-ItemProperty -Path $RegPath -Name $Name -Value 0

    $CV = "dontdisplaylastusername 0으로 설정"
    $result = "양호"
    Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV

}

###############################################

############# 53. 로컬 로그온 허용 ############

$index = "53"
$title = "로컬 로그온 허용"

$RV = "Administrator, IUSR_ 만 존재"
$importance = "중"
$CV = @()

if($trueIndexes -contains $index) {
    # 파일 내용 전체를 가져옵니다.
    $fileContent = Get-Content $securityTemplatePath

    # SeInteractiveLogonRight 항목을 찾고, 새로운 값으로 변경합니다.
    $fileContent = $fileContent -replace "SeInteractiveLogonRight\s*=\s*\*S-1-5.*", "SeInteractiveLogonRight = *S-1-5-32-544,*S-1-5-32-568"

    # 수정된 내용을 파일에 다시 저장합니다.
    Set-Content -Path $securityTemplatePath -Value $fileContent

    $CV = "SeInteractiveLogonRight 값이 새로운 SID로 변경되었습니다."
    $result = "양호"
    Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV

    # 보안 템플릿 임포트
    secedit /configure /db $databasePath /cfg $securityTemplatePath

    SecEdit /export /cfg $securityTemplatePath
}

###############################################

###### 54. 익명 SID/ 이름 변환 허용 해제  ######

$index = "54"
$title = "익명 SID/ 이름 변환 허용 해제"

$RV = "사용 안 함"
$importance = "중"

if($trueIndexes -contains $index) {
    # LSAAnonymousNameLookup 항목 찾기
    $tempStr = Get-Content $securityTemplatePath | Select-String "LSAAnonymousNameLookup"

    $tempStr = $tempStr -replace "LSAAnonymousNameLookup\s*=\s*\d+", "LSAAnonymousNameLookup = 0"

    # 파일 내용 전체를 가져와서 수정된 내용을 반영합니다.
    $fileContent = Get-Content $securityTemplatePath

    # LSAAnonymousNameLookup 라인을 수정합니다.
    $fileContent = $fileContent -replace "LSAAnonymousNameLookup\s*=\s*\d+", $tempStr

    # 수정된 내용을 파일에 다시 저장
    Set-Content -Path $securityTemplatePath -Value $fileContent

    $CV = "LSAAnonymousNameLookup 0으로 설정"
    $result = "양호"
    Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV
}

###############################################

############## 55. 최근 암호 기억 ##############

$index = "55"
$title = "최근 암호 기억"

$RV = "4(개)이상"
$importance = "중"

if($trueIndexes -contains $index) {
    # PasswordHistorySize 항목 찾기
    $tempStr = Get-Content $securityTemplatePath | Select-String "PasswordHistorySize"

    $tempStr = $tempStr -replace "PasswordHistorySize\s*=\s*\d+", "PasswordHistorySize = 4"

    # 파일 내용 전체를 가져와서 수정된 내용을 반영합니다.
    $fileContent = Get-Content $securityTemplatePath

    # PasswordHistorySize 라인을 수정합니다.
    $fileContent = $fileContent -replace "PasswordHistorySize\s*=\s*\d+", $tempStr

    # 수정된 내용을 파일에 다시 저장
    Set-Content -Path $securityTemplatePath -Value $fileContent

    $CV = "PasswordHistorySize 4로 설정"
    $result = "양호"
    Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV

}

###############################################

###### 56. 콘솔 로그온 시 로컬 계정에서 빈 암호 사용 제한 ######

$index = "56"
$title = "콘솔 로그온 시 로컬 계정에서 빈 암호 사용 제한"

$RV = "사용"
$importance = "중"

if($trueIndexes -contains $index) {
    $RegPath = "HKLM:SYSTEM\CurrentControlSet\Control\Lsa"
    $Name = "LimitBlankPasswordUse"
    
    $var = Get-ItemPropertyValue -Path $RegPath -Name $Name
    
    # 현재 값 읽기
    $currentValue = Get-ItemPropertyValue -Path $RegPath -Name $Name
    
    # 값을 0으로 변경
    Set-ItemProperty -Path $RegPath -Name $Name -Value 1
    
    $CV = "LimitBlankPasswordUse 1로 설정"
    $result = "양호"
    Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV
    
}

###############################################

###### 57. 원격터미널 접속 가능한 사용자 그룹 제한 ######

$index = "57"
$title = "원격터미널 접속 가능한 사용자 그룹 제한"

$RV = "관리자가 아닌 별도의 원격접속 계정이 존재"
$importance = "중"
$CV = @()

if($trueIndexes -contains $index) {
    $result = "수동"

    $CV = "관리자가 아닌 별도의 원격접속 계정을 생성해 주세요"
    $result = "양호"
    Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -RV $RV
    
}

# 보안 템플릿 임포트
secedit /configure /db $databasePath /cfg $securityTemplatePath

SecEdit /export /cfg $securityTemplatePath

###############################################

#############################################################################################################################