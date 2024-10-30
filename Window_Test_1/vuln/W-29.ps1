###############################################

########### 29. DNS Zone Transfer 설정 ###########


$index = $checklist.check_list[28].code
$title = $checklist.check_list[28].title
$root_title = $checklist.check_list[28].root_title
$RV = "DNS 서비스 사용X / 영역 전송 허용X / 특정 서버로만 설정"
$importance = $checklist.check_list[28].importance

$result = "수동"
$CV = "DNS 서버 사용 여부 확인 필요"
# $total_dns_count = 0

# $tempSTR = @()
# try {
#     $DNS_Zone_list = Get-DnsServerZone | Select-Object ZoneName

#     $flag = Get-Service *DNS* | Select-Object "Status"

#     if($flag -like "*Running*")
#     {
#         if($DNS_Zone_list.length -gt 0)
#         {
#             foreach($zone_item in $DNS_Zone_list)
#             {
#                 $zone_item = $zone_item | Format-Wide
#                 $Zone_Name = String $zone_item
             
#                 $flag = (Get-DnsServerZone -ZoneName $Zone_Name).SecureSecondaries

#                 if($flag -like "*NoTransfer*")
#                 {
#                     $result = "양호" 
#                 }
#                 elseif($flag -like "*TransferToSecureServers*")
#                 {
#                     $result = "양호"
#                 }
#                 elseif($flag -like "*TransferToZoneNameServer*")
#                 { 
#                     $result = "취약"
#                     $total_dns_count++
#                     $tempSTR += $Zone_Name
#                     $tempSTR += ','
#                 }
#                 elseif($flag -like "*TransferAnyServer*")
#                 {
#                     $result = "취약"
#                     $total_dns_count++
#                     $tempSTR += $Zone_Name
#                     $tempSTR += ','
#                 }
#             }
#             if($tempSTR.count -gt 0)
#             {
#                 $tempSTR[-1] = ''  
#             }
#         }
#         else
#         {
#             $result = "양호"
#         }

#         if($total_dns_count -gt 0)
#         {
#             $CV = ("DNS Zone Transfer 차단 설정이 되어 있지 않은 Zone은 " + $tempSTR + " 입니다.")
#             $result = "취약"
#         }
#         else
#         {
#             $CV = ("모든 Zone이 차단 설정이 되어 있습니다.")
#             $result = "양호"
#         }
#     }
# }
# catch {
#     $CV = "해당 서버는 DNS 관련 서비스를 사용하고 있지 않습니다."
#     $result = "양호"
# }

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title