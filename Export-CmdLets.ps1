##########################
# Author: Justin Henderson
# Last Update: 9/16/2017
# Version:     1.0
#
# Description
#
# This script is used to export a list of unique PowerShell Cmdlets used on 
# a system. It can be used to generate a whitelist of "normal" cmdlets. This
# can be used to compare against an incident or unknown PowerShell events.
#
# When combined with something like Compare-Object it can greatly reduce the
# amount of data you have to investigate or can be used to implement automatic
# alerting. For example, in SEC555: SIEM with Tactical Analytics PowerShell
# cmdlets are exported and then used as a whitelist. All new PowerShell cmdlets
# are then monitored and alerted on.
##############################

function Get-CmdLets ($computer, $evtx){
    if(Get-Variable computer -Scope Global -ErrorAction SilentlyContinue){
        $events = Get-WinEvent -FilterHashtable @{Path=$evtx; ProviderName=“Microsoft-Windows-PowerShell”; Id = 4103 }
    } else {
        if(Get-Variable computer -Scope Global -ErrorAction SilentlyContinue) {
            $events = Get-WinEvent -ComputerName $computer -FilterHashtable @{ProviderName=“Microsoft-Windows-PowerShell”; Id = 4103 }
        } else {
            $events = Get-WinEvent -FilterHashtable @{ProviderName=“Microsoft-Windows-PowerShell”; Id = 4103 }
        }
    }
    $cmdlets = @()
    $events.Message | ForEach-Object {
        # Lowercase all characters to greatly reduce possible values
        $string = $_.ToLower()
        [regex]::Match($string,'^commandinvocation\((.+)\)').captures.groups[1] | ForEach-Object {
            if (-not ($cmdlets -contains $_)){
                $cmdlets += $_.value
            }
        }
    }
    $cmdlets | Select -Unique | Sort-Object
}
$original_list = @("Add-Member","Foreach-Object","Get-Item")
$new_list
Compare-Object -ReferenceObject $original_list -DifferenceObject $new_list | Where-Object { $_.SideIndicator -eq '=>' } | Select -ExpandProperty InputObject