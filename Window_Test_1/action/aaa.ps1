# 레지스트리 경로 및 키 설정
$regPath = "HKLM\SYSTEM\CurrentControlSet\Control\Lsa"
$keyName = "crashonauditfail"

# 현재 값 가져오기
$existingValue = Get-RegistryValue $regPath | Where-Object { $_.Name -like "*$keyName*" }

if ($existingValue) {
    # 값이 존재하면 0으로 설정
    Set-RegistryValue -Path $regPath -Name $keyName -Value 0 -Type DWord
    Write-Host "레지스트리 키 '$keyName'의 값을 0으로 설정했습니다."
} else {
    # 값이 없으면 추가
    Set-RegistryValue -Path $regPath -Name $keyName -Value 0 -Type DWord
    Write-Host "레지스트리 키 '$keyName'이 없어서 새로 추가하고 값을 0으로 설정했습니다."
}
