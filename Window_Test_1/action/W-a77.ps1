###############################################

########### 77. LAN Manager 인증 수준 ###########

$index = $checklist.check_list[76].code
$title = $checklist.check_list[76].title
$root_title = $checklist.check_list[76].root_title

$importance = $checklist.check_list[76].importance

$flag = (Get-RegistryValue "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" | Where-Object { $_.Name -eq "LmComPatibilityLevel" }).Value
if ($flag) {
    if ($flag -ge 3) {
        $result = "양호"
        $CV = "현재 LAN Manager 인증 수준은 'NTLMv2' 입니다."
    }
    else {
        $result = "취약"

        switch ($flag) {
            0 { $CV = "현재 LAN Manager 인증 수준은 'NTLMv2' 입니다." }
            1 { $CV = "현재 LAN Manager 인증 수준은 'LM 및 NTLM 응답 보내기 - 협상되면 NTLMv2 세션 보안 사용'" }
            2 { $CV = "현재 LAN Manager 인증 수준은 'NTLM 응답만 보내기' 입니다." }
            # 4 {$CV = "현재 LAN Manager 인증 수준은 'NTLMv2 응답만 보내기 및 LM 거부' 입니다."}
            # 5 {$CV = "현재 LAN Manager 인증 수준은 'NTLMv2 응답만 보냅니다. LM 및 NTLM은 거부합니다.'"}
            default {}
        }
    }
}
else {
    $result = "취약"
    $CV = "LAN Manager 인증 수준을 설정하지 않았습니다."
}

Add-Data -index $index -root_title $root_title -title $title -result $result -CV $CV -importance $importance -category $root_title