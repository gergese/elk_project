###############################################

########### 63. DNS 서비스 구동 점검 ###########

$index = $checklist.check_list[62].code
$title = $checklist.check_list[62].title
$root_title = $checklist.check_list[62].root_title
$importance = $checklist.check_list[62].importance

# Get all DNS zones on the DNS server
$dnsZones = Get-DnsServerZone

foreach ($zone in $dnsZones) {
    # Disable dynamic updates for the DNS zone
    Set-DnsServerZone -Name $zone.ZoneName -DynamicUpdate None
    
    Write-Host "Dynamic updates disabled for zone: $($zone.ZoneName)"
}

# Verify the configuration
foreach ($zone in $dnsZones) {
    $zoneConfig = Get-DnsServerZone -Name $zone.ZoneName
    Write-Host "Zone: $($zone.ZoneName), Dynamic Update Setting: $($zoneConfig.DynamicUpdate)"
}

$CV = "DNS 동적 업데이트 비활성화"
$result = "양호"

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title