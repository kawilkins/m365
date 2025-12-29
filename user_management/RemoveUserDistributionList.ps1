<#
.SYNOPSIS
    Remove a user from a distribution list.

.DESCRIPTION
    Script will remove a user from a distribution list.

.AUTHOR
    Kevin Wilkins
    kwilkinsrd@gmail.com

.CREATED
    03/14/2025

.VERSION
    0.1.0

.NOTES
    Cmdlets used and their documentation:
    - https://learn.microsoft.com/en-us/powershell/module/exchangepowershell/remove-distributiongroupmember?view=exchange-ps
#>

$config = Import-PowershellDataFile -Path .\mstenant.psd1
$tenant = $config.domain

$userName = Read-Host "Username"
$distList = Read-Host "Distribution List"

$distListParams = @{
    Identity = "$distList@$tenant"
    Member = "$userName@$tenant"
    Confirm = $false
}
Remove-DistributionGroupMember @distListParams
Get-DistributionGroupMember -Identity "$distlist@$tenant" | Select-Object DisplayName,PrimarySmtpAddress
