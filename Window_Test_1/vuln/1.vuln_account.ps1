# 문서화를 위한 결과 저장 변수
$index=0
$root_title="계정 관리"
$title=0
$result=0
$result_act=0

#Recommanded Value
$RV = 0

#Current value
$CV = 0

#비고란
$importance = 0

############################################# < 1 . 계정 관리 취약점 항목 점검> #############################################

#############################################################################################################################

$index="01"
$title="계정 관리 취약점 항목 점검"

try{
    $Active_DIR_Service = Get-ADDefaultDomainPasswordPolicy
}
catch
{
    $Active_DIR_Service = 0
}

###### 1. Administrator 계정 이름 바꾸기 ######   

$RV = "Administrator가 아닌 다른 값"
$importance = "상"
$result_act = $false
$var = (Get-LocalUser Administrator).length

if($var -gt 0)
{
    $result = "취약"

    $CV = "Administrator, Default 계정 이름 변경 필요"
}
else
{
    $result = "양호"

    $f1 = (Get-LocalGroupMember -Name "Administrators").Name
    $f1 = Out-String -InputObject $f1
    $f1 = $f1.Split("\")
    $CV = $f1[-1]
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

############# 2. Guest 계정 상태 ##############

$index="02"
$title="Guest 계정 상태"

$RV = "Guest 계정 비활성화"
$importance = "상"
$result_act = $true
$var = Get-LocalUser -Name Guest | Select-Object Enabled | Format-Wide

if($var -eq 'True')
{
    $result = "취약"

    $CV = "Guest 계정 활성화"
}
else
{
    $result = "양호"

    $CV = "Guest 계정 비활성화"
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

############ 3. 불필요한 계정 제거 ############

$index="03"
$title="불필요한 계정 제거"
$result="수동"
$result_act = $false
$RV = "불필요한 계정 제거"
$importance = "상"
$CV = "활성화된 계정들 중 불필요한 계정은 삭제하여 주세요."
$account_list = Get-LocalUser | Where-Object { $_.Enabled -eq $true } | Select-Object -ExpandProperty Name

$CV += "활성화된 계정 목록 : $account_list"
Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

########### 4. 계정 잠금 임계값 설정 ###########

$index="04"
$title="계정 잠금 임계값 설정"
$result_act = $true
$RV = "5이하"
$importance = "상"

$tempStr = Get-Content user_rights.inf | Select-String "LockoutBadCount"
$tempStr = Out-String -InputObject $tempStr
$tempStr = $tempStr.Split('=')
$count = $tempStr[-1].Trim()


if($count)
{
    if($count -eq 0)
    {
        $result = "취약"
        $CV = $count
        $CV = $CV
        $CV = "계정 잠금 임계값 미 설정"
    }
    elseif($count -le 5)
    {
        $result = "양호"
        $CV = $count
        $CV = $CV
        $CV = "현재 계정 잠금 임계값은 " + $CV + "회"
    }
    elseif($count -ge 6)
    {
        $result = "취약"
        $CV = $count
        $CV = $CV
        $CV = "현재 계정 잠금 임계값은 " + $CV + "회"
    }
}
else
{
    $result = "취약"
    $CV = "계정 잠금 임계값 미 설정"
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

###### 5. 해독 가능한 암호화를 사용하여 암호 저장 해제 ######

$index="05"
$title="해독 가능한 암호화를 사용하여 암호 저장 해제"
$result_act = $true
$RV = "사용 안 함"
$importance = "상"

$tempStr = Get-Content user_rights.inf | Select-String "PasswordComplexity"
$tempStr = Out-String -InputObject $tempStr
$tempStr = $tempStr.Split('=')
$count = $tempStr[-1].Trim()


if($count)
{
    $result = "취약"
    $CV = "해당 옵션 사용 중"
}
else
{
    $result = "양호"
    $CV = "해당 옵션 사용 안 함"
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

###### 6. 관리자 그룹에 최소한의 사용자 포함 ######

$index="06"
$title="관리자 그룹에 최소한의 사용자 포함"
$result = "수동"
$result_act = $false
$tempStr = @()

$RV = "구성원 1명 이하로 유지 / 불필요한 관리자 계정 존재 X"
$importance = "상"

foreach($item in (Get-LocalGroupMember -Name Administrators).Name)
{
    $item = $item.Split('\')
    $item = $item[-1]
    $tempStr += $item
    $tempStr += ',' 
}

if($tempSTR.count -gt 0)
{
    $tempSTR[-1] = ''
}

$CV = "불필요한 관리자 그룹 사용자 획인 필요. 관리자 그룹 사용자 : " + $tempStr

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

###### 46. Everyone 사용권한을 익명사용자에 적용 해제 ######

$index="46"
$title="Everyone 사용권한을 익명사용자에 적용 해제"
$result_act = $true
$RV = "사용 안 함"
$importance = "중"

$RegPath = "HKLM:SYSTEM\CurrentControlSet\Control\Lsa"
$Name = "everyoneincludesanonymous"

$var = Get-ItemPropertyValue -Path $RegPath -Name $Name

if(!$var)
{
    $result = "양호"
    $CV = "Everyone 사용권한을 익명사용자에 적용 해제"
}
else
{
    $result = "취약"
    $CV = "Everyone 사용권한을 익명사용자에 적용"
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

########### 47. 계정 잠금 기간 설정 ###########

$index="47"
$title="계정 잠금 기간 설정"
$result_act = $true
$RV = "60(분)이상"
$importance = "중"

$tempStr = Get-Content user_rights.inf | Select-String "LockoutDuration"
$tempStr = Out-String -InputObject $tempStr
$tempStr = $tempStr.Split('=')
$count = $tempStr[-1].Trim()


if($count)
{
    if($count -ge 60)
    {
        $result = "양호"
        $CV = $count.ToString() + "분"
    }
    else
    {
        $result = "취약"
        $CV = $count.ToString() + "분"
    }
}
else
{
    $result = "취약"
    $CV = "값이 설정되어 있지 않습니다."
}

# 1) Get-ADDefaultDomainPasswordPolicy 명령어를 입력한다
# 2) LockoutDuration , LockoutObsercationWindow 값을 확인 한다

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

########### 48. 패스워드 복잡성 설정 ##########

$index="48"
$title="패스워드 복잡성 설정"
$result_act = $true
$RV = "사용"
$importance = "중"

$tempStr = Get-Content user_rights.inf | Select-String "PasswordComplexity"
$tempStr = Out-String -InputObject $tempStr
$tempStr = $tempStr.Split('=')
$count = $tempStr[-1].Trim()


if($count)
{
    $result = "양호"
    $CV = "해당 옵션 사용 중"
}
else
{
    $result = "취약"
    $CV = "해당 옵션 사용 안 함"
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

######## 49. 패스워드 최소 암호 길이 ##########

$index="49"
$title="패스워드 최소 암호 길이"
$result_act = $true
$RV = "8(자)이상"
$importance = "중"

$tempStr = Get-Content user_rights.inf | Select-String "MinimumPasswordLength"
$tempStr = Out-String -InputObject $tempStr
$tempStr = $tempStr.Split('=')
$count = $tempStr[-1].Trim()


if($count)
{
    if($count -ge 8)
    {
        $result = "양호"
        $CV = $count
        $CV = $CV
        $CV += "자"
    }
    else
    {
        $result = "취약"
        $CV = $count
        $CV = $CV
        $CV += "자"
    }
}
else
{
    $result = "취약"
    $CV = "해당 옵션이 설정되어 있지 않습니다."
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

######### 50. 패스워드 최대 사용 기간 #########

$index="50"
$title="패스워드 최대 사용 기간"
$result_act = $true
$RV = "90(일)이하"
$importance = "중"

$tempStr = Get-Content user_rights.inf | Select-String "MaximumPasswordAge = "
$tempStr = Out-String -InputObject $tempStr
$tempStr = $tempStr.Split('=')
$count = $tempStr[-1].Trim()

if($count)
{
    if($count -le 90 -and $count -ne 0)
    {
        $result = "양호"
        $CV = $count
        $CV = $CV.Trim()
        $CV += "일"
    }
    else
    {
        $result = "취약"
        $CV = $count
        $CV = $CV.Trim()
        $CV += "일"
    }
}
else
{
    $result = "취약"
    $CV = "해당 옵션이 설정되어 있지 않습니다."
}

# 1) Get-ADDefaultDomainPasswordPolicy 명령어를 입력한다
# 2) MaxPasswordAge 값을 확인한다

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

######### 51. 패스워드 최소 사용 기간 #########

$index="51"
$title="패스워드 최소 사용 기간"
$result_act = $true
$RV = "0보다 큰 값"
$importance = "중"

$tempStr = Get-Content user_rights.inf | Select-String "MinimumPasswordAge"
$tempStr = Out-String -InputObject $tempStr
$tempStr = $tempStr.Split('=')
$count = $tempStr[-1].Trim()


if($count)
{
    if($count -gt 0)
    {
        $result = "양호"
        $CV = $count
        $CV = $CV
        $CV += "일"
    }
    else
    {
        $result = "취약"
        $CV = $count
        $CV = $CV
        $CV += "일"
    }
}
else
{
    $result = "취약"
    $CV = "설정X"
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

###### 52. 마지막 사용자 이름 표시 안 함 ######

$index="52"
$title="마지막 사용자 이름 표시 안 함"
$result_act = $true
$RV = "사용"
$importance = "중"

$RegPath = "HKLM:Software\Microsoft\Windows\CurrentVersion\Policies\System"
$Name = "dontdisplaylastusername"

$var = Get-ItemPropertyValue -Path $RegPath -Name $Name

if($var)
{
    $result = "양호"
    $CV = "해당 옵션 사용 중"
}
else
{
    $result = "취약"
    $CV = "해당 옵션 사용 안 함"
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

############# 53. 로컬 로그온 허용 ############

$index="53"
$title="로컬 로그온 허용"
$result_act = $false
$RV = "Administrator, IUSR_ 만 존재"
$importance = "중"
$CV = @()

$String_1 = Get-content ./user_rights.inf | Select-String "SeInteractiveLogonRight"
$String_1 = Out-String -InputObject $String_1

$String_1 = $String_1 -replace "`\s+",''

$String_2 = $String_1.Split("*,")
$SID_List = @()
$count = 0

for($X=1;$X -lt $String_2.count;$X++)
{
    if($String_2[$X].length -ne 0)
    {
        $SID_List += $String_2[$X]
    }
}

foreach($SID_ITEM in $SID_List)
{
    $flag = Convert_SID_TO_USERNAME $SID_ITEM

    $flag = Out-String -InputObject $flag
    $flag = $flag.Split('\')
    $flag = $flag[-1].Trim()

    $CV += $flag
    $CV += ','

    if(!($flag -like "*Administrator*" -or $flag -like "*IUSR*"))
    {
        $count++
    }
}

$CV[-1] = ''

if($count -eq 0)
{
    $result = "양호"
}
else
{
    $result = "취약"
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

###### 54. 익명 SID/ 이름 변환 허용 해제  ######

$index="54"
$title="익명 SID/ 이름 변환 허용 해제"
$result_act = $true
$RV = "사용 안 함"
$importance = "중"

$flag = (Get-content ./user_rights.inf | Select-String "LSAAnonymousNameLookup" | Select-String "0").count

if($flag -eq 0)
{
    $result = "취약"
    $CV = "해당 옵션 사용 중"

}
else
{
    $result = "양호"
    $CV = "해당 옵션 사용 안 함"
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

############## 55. 최근 암호 기억 ##############

$index="55"
$title="최근 암호 기억"
$result_act = $true
$RV = "4(개)이상"
$importance = "중"

$tempStr = Get-Content user_rights.inf | Select-String "PasswordHistorySize"
$tempStr = Out-String -InputObject $tempStr
$tempStr = $tempStr.Split('=')
$count = $tempStr[-1].Trim()

if($count)
{
    if($count -ge 4)
    {
        $result = "양호"
        $CV = $count
        $CV = $CV
        $CV += "개"
    }
    else
    {
        $result = "취약"
        $CV = $count
        $CV = $CV
        $CV += "개"
    }
}
else
{
    $result = "취약"
    $CV = "해당 옵션이 설정되어 있지 않습니다."
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

###### 56. 콘솔 로그온 시 로컬 계정에서 빈 암호 사용 제한 ######

$index="56"
$title="콘솔 로그온 시 로컬 계정에서 빈 암호 사용 제한"
$result_act = $true
$RV = "사용"
$importance = "중"

$RegPath = "HKLM:SYSTEM\CurrentControlSet\Control\Lsa"
$Name = "LimitBlankPasswordUse"

$var = Get-ItemPropertyValue -Path $RegPath -Name $Name

if($var)
{
    $result = "양호"
    $CV = "해당 옵션 사용 중"
}
else
{
    $result = "취약"
    $CV = "해당 옵션 사용 안 함"
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

###### 57. 원격터미널 접속 가능한 사용자 그룹 제한 ######

$index="57"
$title="원격터미널 접속 가능한 사용자 그룹 제한"
$result_act = $false
$RV = "관리자가 아닌 별도의 원격접속 계정이 존재"
$importance = "중"
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

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -result_act $result_act -RV $RV

###############################################

#############################################################################################################################