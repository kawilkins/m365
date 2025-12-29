<#
.SYNOPSIS
    Authenticate and connect to Microsoft 365

.DESCRIPTION
    Script will import tenant information from the PowerShell data file
    and authenticate user checking against if user is an administrator.

.AUTHOR
    Kevin Wilkins
    kwilkinsrd@gmail.com

.CREATED
    07/14/2025

.VERSION
    0.1.0

.NOTES
    Cmdlets used and their documentation:
    - Connect-ExchangeOnine: https://learn.microsoft.com/en-us/powershell/module/exchangepowershell/connect-exchangeonline?view=exchange-ps
#>

$config = Import-PowershellDataFile -Path .\mstenant.psd1
$tenant = $config.domain
$username = Read-Host "Username"

$exchangeonline = @{
    UserPrincipalName = "$username@$tenant"
    ShowBanner = $false
}
Connect-ExchangeOnline @exchangeonline
Write-Output "Connected to Microsoft ExchangeOnline."
