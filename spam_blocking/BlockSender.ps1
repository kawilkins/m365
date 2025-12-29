<#
.SYNOPSIS
    Adds senders to tenant block list.

.DESCRIPTION
    Script reads list of domains from a CSV file and adds each domain to
    the senders tenant block list.

.AUTHOR
    Kevin Wilkins
    kwilkinsrd@gmail.com

.CREATED
    03/06/2025

.VERSION
    0.1.0

.NOTES
    Cmdlets used and their documentation:
    - New-TenantAllowBlockListItems: https://learn.microsoft.com/en-us/powershell/module/exchangepowershell/new-tenantallowblocklistitems?view=exchange-ps
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

$blockDomains = ".\spamDomains.csv"
$domains = Import-Csv -Path $blockDomains

foreach ($domain in $domains) {
    $denyDomain = $domain.Domain

    $blockItems = @{
        ListType = "Sender"
        Block = $true
        Entries = "$denyDomain"
        NoExpiration = $true
    }
    New-TenantAllowBlockListItems @blockItems
}

Disconnect-ExchangeOnline -Confirm:$false
Write-Output "Disconnected from Microsoft Exchange Online."
