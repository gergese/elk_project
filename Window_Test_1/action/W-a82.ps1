###############################################

########### 82. Windows 인증 모드 사용 ###########

$index = $checklist.check_list[81].code
$title = $checklist.check_list[81].title
$root_title = $checklist.check_list[81].root_title
$result = "수동"

$importance = $checklist.check_list[81].importance

$CV = "수동 점검"

#HKEY_LOCAL_MACHINE\Software\Microsoft\Microsoft SQL Server\<Instance Name>\MSSQLServer\LoginMode
# 1 : Windwos 인증만
# 2 : 혼합 모드 인증

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title