###############################################

########### 66. 불필요한 ODBC / OLE-DB 데이터 소스와 드라이브 제거 ###########

$index = $checklist.check_list[65].code
$title = $checklist.check_list[65].title
$root_title = $checklist.check_list[65].root_title
$importance = $checklist.check_list[65].importance

# ODBC 데이터 원본 목록 가져오기
$odbc_list = Get-OdbcDsn

# ODBC 데이터 원본이 존재하는지 확인
if ($odbc_list) {
    # ODBC 데이터 원본이 존재할 경우, 각 데이터 원본 제거
    foreach ($odbc in $odbc_list) {
        # ODBC 데이터 원본 제거
        Remove-OdbcDsn -Name $odbc.Name -DsnType $odbc.DsnType
    }
}

$CV = "ODBC 데이터 원본 삭제"
$result = "양호"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title