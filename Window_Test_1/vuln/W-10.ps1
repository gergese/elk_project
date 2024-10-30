###############################################

########### 10 .IIS 서비스 구동 점검 ##########

$index = $checklist.check_list[9].code
$title = $checklist.check_list[9].title
$root_title = $checklist.check_list[9].root_title
$result = "수동"
$importance = $checklist.check_list[9].importance
$CV = "IIS 서비스 사용 여부 확인 필요"
# $IIS_Services = @("IISADMIN","FTPSVC","W3SVC","WAS")

# $count = 0

# $tempSTR = @()


# foreach($item in $IIS_Services)
# {
#     $var = Get-Service | Where-Object {$_.Status -eq 'Running'} | Where-Object {$_.Name -like $item} | Format-List
#     if($var.length -gt 0)
#     {
#         $tempSTR += $item
#         $tempSTR += ','

#         $count++
#     }
# }

# if($tempSTR.count -gt 0)
# {
#     $tempSTR[-1] = ''
# }

# if($count -gt 0)
# {
#     $result = "취약"
#     $CV = ("구동중인 IIS 서비스는 " + $tempSTR)
# }
# else
# {
#     $result = "양호"
#     $CV = ("구동중인 IIS 서비스는 없습니다.")
# }

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title