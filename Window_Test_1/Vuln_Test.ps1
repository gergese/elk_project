# 입력값 받아오기
param (
    [int[]]$SelectedFiles  # 실행할 파일 번호 배열
)

function Test-Role {
    Param([Security.Principal.WindowsBuiltinRole]$Role )
    $CurrentUser = [Security.Principal.WindowsPrincipal]([Security.Principal.WindowsIdentity]::GetCurrent())
    $CurrentUser.IsInRole($Role)
}

# 공백 / 줄바꿈이 존재하는 object형 결과값을 공백없는 String형 결과값으로 바꿔주는 함
function String([object]$string) {
    $string_return = Out-String -InputObject $string
    $string_return = $string_return.Split(" ")[0]
    $string_return = $string_return.Split("`r")[2]
    $string_return = $string_return.Split("`n")[1]

    return $string_return
}

# 경로의 권한을 얻어온다.
function Get-Permissions($Path) {
    (Get-Acl -Path $Path).Access | select 
    @{Label = "identity"; Expression = { $_.IdentityReference } }
}

# 레지스트리 키 이름, 타입, 값을 출력해준다.
function Get-RegistryValue {
    param
    (
        [Parameter(Mandatory = $true)]
        $RegistryKey
    )

    $key = Get-Item -Path "Registry::$RegistryKey"
    $key.GetValueNames() |
    ForEach-Object {
        $name = $_
        $rv = 1 | Select-Object -Property Name, Type, Value
        $rv.Name = $name
        $rv.Type = $key.GetValueKind($name)
        $rv.Value = $key.GetValue($name)
        $rv
  
    }
}

# 입력된 경로의 레지스트리 키가 존재하는지 확인한다.
function Test-RegistryValue($regkey, $name) {
    try {
        $exists = Get-ItemProperty $regkey $name -ErrorAction SilentlyContinue
        if (($exists -eq $null) -or ($exists.Length -eq 0)) {
            return $false
        }
        else {
            return $true
        }
    }
    catch {
        return $false
    }
}

#SID를 계정이름으로 변경해준다.
function Convert_SID_TO_USERNAME($SID) {
    $objSID = New-Object System.Security.Principal.SecurityIdentifier($SID)
    $objUser = $objSID.Translate( [System.Security.Principal.NTAccount])
    return ($objUser.Value)
}


#관리자 계정으로 점검하는지 확인

$Current = Test-Role "Administrator"

if (!$Current) {
    exit 5
}

# 검사에 필요한 명령문을 사용하기 위한 Module Import
$Use_Module_List = @("WebAdministration", "ActiveDirectory", "DnsServer", "PSWindowsUpdate")

#모듈 설정

foreach ($module_item in $Use_Module_List) {
    if ((Get-Module -Name $module_item).count -ne 0) {

        try {
            # 모듈을 사용한다.
            Import-Module -Name $module_item -Force
        }
        catch {
            # 만약 사용할 모듈이 설치되어 있지 않다면 해당 모듈을 설치한다.
            Install-Module -Name $module_item -Force 
        }
    }
}

# 보안 정책 내보내기
SecEdit /export /cfg ./user_rights.inf

#################### IIS 서비스 관련 취약점 점검에 자주 사용되는 IIS 버전은 미리 구해둔다. ####################
try {
    $IIS_version = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\InetStp\  | select setupstring | Format-Wide

    # Object형 결과 값 String형으로 변환
    $IIS_version = Out-String -InputObject $IIS_version

    # "IIS xxx" 부분에서 숫자 부분 출력
    $IIS_version = $IIS_version.Split(" ")[1]

    # String형 값 -> INT 형으로 바꾸기
    $IIS_version = $IIS_version -as [int]
}
catch {}
#############################################################################################################

#################### IIS 사이트 이름과 경로는 자주 점검에 자주 사용되므로 미리 구해둔다. ####################

$IIS_Site_List = Get-IISSite | select-Object Name

$Site_Name_list = @()
$Site_Path_list = @()
$Site_Path_Full_Path_list = @()

foreach ($name_item in $IIS_Site_List) {
    $name_item = $name_item | Format-Wide

    # 공백 , newline 문자열을 버리고 이름만 추출
    $Site_Name = String $name_item
    $Site_Name_list += $Site_Name

    $Site_Path = 'IIS:\Sites\' + $Site_Name
    $Site_Path_list += $Site_Path

    # 드라이브 이름으로 시작하는 (EX : C\..) 실제 경로
    $Site_Path = (Get-WebFilePath $Site_Path).FullName
    $Site_Path_Full_Path_list += $Site_Path

}

#############################################################################################################

#################### FTP 사이트 이름과 경로는 자주 점검에 자주 사용되므로 미리 구해둔다. ####################

$FTP_Site_List = Get-IISSite | Where-Object { $_.Bindings -like "*ftp*" } | select-Object Name

$FTP_Site_Name_list = @()
$FTP_Site_Path_list = @()
$FTP_Site_Path_Full_Path_list = @()

foreach ($name_item in $FTP_Site_List) {
    $name_item = $name_item | Format-Wide

    # 공백 , newline 문자열을 버리고 이름만 추출
    $Site_Name = String $name_item
    $FTP_Site_Name_list += $Site_Name

    $Site_Path = 'IIS:\Sites\' + $Site_Name
    $FTP_Site_Path_list += $Site_Path

    # 드라이브 이름으로 시작하는 (EX : C\..) 실제 경로
    $Site_Path = (Get-WebFilePath $Site_Path).FullName
    $FTP_Site_Path_Full_Path_list += $Site_Path

}

$securityTemplatePath = ".\user_rights.inf"
$databasePath = ".\test.sdb"

# 전역 변수 선언
$global:data_json = @()

# 체크리스트 JSON 데이터 읽기
$checklist = Get-Content -Path ".\window_checklist.json" | Out-String | ConvertFrom-Json

$hardware_uuid = (Get-WmiObject -Class Win32_ComputerSystemProduct).UUID

$os_info = Get-CimInstance -ClassName Win32_OperatingSystem
$os_name = $os_info.Caption

# json 형식
function Add-Data {
    param (
        [string]$index,
        [string]$category,
        [string]$title,
        [string]$result,
        [string]$importance,
        [string]$CV
    )

    # 새 데이터를 배열에 추가
    $newData = @{
        분류   = $category
        중요도  = $importance
        점검항목 = $title
        항목코드 = $index
        상태   = $CV
        결과   = $result
        hwid = $hardware_uuid
        점검자  = "송재민"
        점검대상 = $os_name
    }

    # 요청을 보낼 URL 설정 (예: 로컬호스트 5000번 포트)
    $url = "http://192.168.2.54:5000"

    $json = $newData | ConvertTo-Json -Depth 10

    # \u0027을 작은따옴표로 변환
    $json = $json -replace '\\u0027', "'"

    # UTF-8로 인코딩
    $utf8Bytes = [System.Text.Encoding]::UTF8.GetBytes($json)

    # JSON 데이터를 5000번 포트로 POST 요청
    $response = Invoke-RestMethod -Uri $url -Method Post -Body $utf8Bytes -ContentType "application/json"

    # 전역 변수에 데이터 추가
    $global:data_json += $newData
}

# 1차 점검

# 파일 경로 및 범위 설정
$scriptDirectory = ".\vuln"
$filePrefix = "W-"
$fileExtension = ".ps1"
$allScripts = 1..82  # W-01 ~ W-82

# 만약 입력값이 없으면 모든 파일을 실행
if (-not $SelectedFiles) {
    $SelectedFiles = $allScripts
}

# 선택된 파일들을 실행
foreach ($fileNumber in $SelectedFiles) {
    
    $fileName = "{0}{1:D2}{2}" -f $filePrefix, $fileNumber, $fileExtension
    $filePath = Join-Path $scriptDirectory $fileName

    # 파일이 존재하는지 확인하고 실행
    if (Test-Path $filePath) {
        Write-Host "Executing $fileName"
        & $filePath
    }
    else {
        Write-Warning "$filePath not found."
    }
}

# 점검 결과 json 파일 저장
# Write-Output $global:data_json | ConvertTo-Json -Depth 10  | Out-File -Encoding utf8 -FilePath "check_output.json"
$json = $global:data_json | ConvertTo-Json -Depth 10

# \u0027을 작은따옴표로 변환
$json = $json -replace '\\u0027', "'"

# JSON 파일로 저장
$json | Set-Content -Path "check_output.json" -Encoding UTF8

# 데이터 초기화
$global:data_json = @()

# JSON 파일 경로
$jsonFile = ".\check_output.json"

# JSON 데이터 읽기
$jsonData = Get-Content -Path $jsonFile | Out-String | ConvertFrom-Json

foreach ($key in $jsonData.PSObject.Properties.Name) {
    # 각 키의 항목들을 순회
    $items = $jsonData.$key
}

# #조치
# # 파일 이름 접두사 및 확장자 설정
# $filePrefix = "W-a"

# # 사용자로부터 실행할 파일 번호 입력 받기
# $fileNumbers = Read-Host "enter fix numbers (ex: 1 2 or 01 02, press enter to skip)"

# # 입력값이 비어있는지 확인
# if (-not [string]::IsNullOrWhiteSpace($fileNumbers)) {
#     # 입력값을 공백으로 분리하여 배열로 변환
#     $fileNumbersArray = $fileNumbers -split ' '

#     # 파일 경로 설정 (현재 폴더에 파일이 있다고 가정)
#     $scriptDirectory = ".\action"  # 파일이 있는 디렉토리

#     # 각 파일 번호에 대해 실행
#     foreach ($fileNumber in $fileNumbersArray) {
#         # 두 자리 숫자로 포맷팅 (01, 02 등)
#         $formattedFileNumber = "{0:D2}" -f [int]$fileNumber

#         # 파일 이름 생성
#         $fileName = "{0}{1}{2}" -f $filePrefix, $formattedFileNumber, $fileExtension
#         $filePath = Join-Path $scriptDirectory $fileName

#         # 파일이 존재하는지 확인하고 실행
#         if (Test-Path $filePath) {
#             Write-Host "Executing $fileName"
#             & $filePath
#         }
#         else {
#             Write-Warning "$filePath not found."
#         }
#     }
# }
# else {
#     Write-Host "skip."
# }


# # 데이터 초기화
# $global:data_json = @()

# # 2차 점검

# # 파일 경로 및 범위 설정
# $scriptDirectory = ".\vuln"
# $filePrefix = "W-"
# $fileExtension = ".ps1"
# $allScripts = 1..82  # 실행할 파일들의 범위 (W-01 ~ W-82)

# # 만약 입력값이 없으면 모든 파일을 실행
# if (-not $SelectedFiles) {
#     $SelectedFiles = $allScripts
# }

# # 선택된 파일들을 실행
# foreach ($fileNumber in $SelectedFiles) {
#     # 숫자를 W- 형식으로 변환 (숫자가 2자리로 표시되도록 포맷)
#     $fileName = "{0}{1:D2}{2}" -f $filePrefix, $fileNumber, $fileExtension
#     $filePath = Join-Path $scriptDirectory $fileName

#     # 파일이 존재하는지 확인하고 실행
#     if (Test-Path $filePath) {
#         Write-Host "Executing $fileName"
#         & $filePath
#     }
#     else {
#         Write-Warning "$filePath not found."
#     }
# }

# # 2차 점검 결과 JSON 저장
# $json = $global:data_json | ConvertTo-Json -Depth 10

# # \u0027을 작은따옴표로 변환
# $json = $json -replace '\\u0027', "'"

# # JSON 파일로 저장
# $json | Set-Content -Path "check_output2.json" -Encoding UTF8

if (Test-Path .\user_rights.inf) {
    Remove-Item .\user_rights.inf
}

if (Test-Path .\test.sdb) {
    Remove-Item .\test.sdb
}

if (Test-Path .\test.jfm) {
    Remove-Item .\test.jfm
}
