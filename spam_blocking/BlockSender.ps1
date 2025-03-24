<#
Author: Kevin Wilkins
Date: 03/06/2025
Description: 
This script will add to the Tenant Allow/Block list.
#>

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
