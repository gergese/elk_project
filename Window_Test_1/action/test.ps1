# 사용자 권한 파일 경로
$securityFilePath = "..\user_rights"

# user_rights 파일 읽기
$content = Get-Content -Path $securityFilePath

# ClearTextPassword 값을 0으로 변경
$content = $content -replace "ClearTextPassword = 1", "ClearTextPassword = 0"

# 파일에 변경된 내용 저장
$content | Set-Content -Path $securityFilePath

# 보안 데이터베이스 경로
$dbFilePath = "C:\Windows\security\database\secedit.sdb"  # 기본 위치 설정

# 데이터베이스 파일이 존재하지 않으면 새로 생성
if (-not (Test-Path -Path $dbFilePath)) {
    # 새 데이터베이스 파일 생성
    secedit /initialize /db $dbFilePath
}

# 보안 설정을 적용 (SECURITYPOLICY 영역)
SecEdit /import /db $dbFilePath /cfg $securityFilePath /overwrite /areas SECURITYPOLICY

# 만약 보안 정책 적용이 제대로 이루어지지 않았다면
if ($LASTEXITCODE -ne 0) {
    Write-Host "보안 정책 적용에 실패했습니다. 오류 코드: $LASTEXITCODE"
} else {
    # 그룹 정책 업데이트
    #gpupdate /force
    Write-Host "ClearTextPassword 값을 0으로 변경하고 보안 설정이 업데이트되었습니다."
}
