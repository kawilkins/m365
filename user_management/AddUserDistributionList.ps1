<#
.SYNOPSIS
    Adds a user to a distribution list

.DESCRIPTION
    This script will receive admin input for:
    1. Username to be added to a distribution list
    2. Distribution list username will be added to

    The script will then add the user to the distribution list.

.AUTHOR
    Kevin Wilkins
    kwilkinsrd@gmail.com

.CREATED
    03/12/2025

.VERSION
    0.1.0

.NOTES
    Cmdlets used and their documentation:
    - Add-DistributionGroupMember: https://learn.microsoft.com/en-us/powershell/module/exchangepowershell/add-distributiongroupmember?view=exchange-ps

    Script requires authentication with Microsoft 365 via the exchangeonline PowerShell module.
#>

$config = Import-PowershellDataFile -Path .\mstenant.psd1
$tenant = $config.domain

$userName = Read-Host "Username"
$distList = Read-Host "Distribution List"

$distListParams = @{
    Identity = "$distList@$tenant"
    Member = "$userName@$tenant"
}
Add-DistributionGroupMember @distListParams
Get-DistributionGroupMember -Identity "$distlist@$tenant" | Select-Object DisplayName,PrimarySmtpAddress
