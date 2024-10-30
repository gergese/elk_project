###############################################

########### 42. SAM 계정과 공유의 익명 열거 허용 안 함 ###########

$index = $checklist.check_list[41].code
$title = $checklist.check_list[41].title
$root_title = $checklist.check_list[41].root_title

$importance = $checklist.check_list[41].importance

# 레지스트리 경로 설정
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"

# 레지스트리 키 이름
$keyNames = @("restrictanonymous", "restrictanonymoussam")

# 값 설정
$newValue = 1

foreach ($keyName in $keyNames) {
  # 현재 값 확인
  $currentValue = Get-ItemProperty -Path $regPath -Name $keyName -ErrorAction SilentlyContinue

  if ($currentValue) {
    # 값이 존재하면 1로 설정
    Set-ItemProperty -Path $regPath -Name $keyName -Value $newValue
  }
  else {
    # 값이 없으면 새로 추가
    New-ItemProperty -Path $regPath -Name $keyName -Value $newValue -PropertyType DWord
  }
}

$CV = "restrictanonymous, restrictanonymoussam 값 1로 설정"
$result = "양호"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title