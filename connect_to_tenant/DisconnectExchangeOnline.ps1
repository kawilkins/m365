<#
.SYNOPSIS
    Disconnect from Microsoft 365

.DESCRIPTION
    Script will disconnect admin from exchangeonline module.

.AUTHOR
    Kevin Wilkins
    kwilkinsrd@gmail.com

.CREATED
    07/14/2025

.VERSION
    0.1.0

.NOTES
    Cmdlets used and their documentation:
    - Disconnect-ExchangeOnine: https://learn.microsoft.com/en-us/powershell/module/exchangepowershell/disconnect-exchangeonline?view=exchange-ps
#>

Disconnect-ExchangeOnline -Confirm:$false
Write-Output "Disconnected from Microsoft Exchange Online."
