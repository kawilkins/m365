<#
.SYNOPSIS
    Add user to a shared mailbox.

.DESCRIPTION
    Script adds user to a Microsoft 365 shared mailbox.
    Access levels grant full read and send permissions.

.AUTHOR
    Kevin Wilkins
    kwilkinsrd@gmail.com

.CREATED
    03/13/2025

.VERSION
    0.1.0

.NOTES
    Cmdlets used and their documentation:
    - Add-MailboxPermission: https://learn.microsoft.com/en-us/powershell/module/exchangepowershell/add-mailboxpermission?view=exchange-ps
    - Add-RecipientPermission: https://learn.microsoft.com/en-us/powershell/module/exchangepowershell/add-recipientpermission?view=exchange-ps
#>

$config = Import-PowershellDataFile -Path .\mstenant.psd1
$tenant = $config.domain

$userName = Read-Host "Username"
$sharedMailbox = Read-Host "Shared Mailbox"

$mailboxParams = @{
    Identity = "$sharedMailbox@$tenant"
    User = "$userName@$tenant"
    AccessRights = "FullAccess"
    AutoMapping = $True
}
$recipientParams = @{
    Identity = "$sharedMailbox@$tenant"
    Trustee = "$userName@$tenant"
    AccessRights = "SendAs"
    Confirm = $False
}

Add-MailboxPermission @mailboxParams
Add-RecipientPermission @recipientParams
