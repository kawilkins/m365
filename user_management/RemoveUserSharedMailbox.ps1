<#
.SYNOPSIS
    Remove user access to a shared mailbox.

.DESCRIPTION
    Script removes a user's access to a Shared Mailbox.

.AUTHOR
    Kevin Wilkins
kwilkinsrd@gmail.com

.CREATED
    03/14/2025

.VERSION
    0.1.0

.NOTES
    Cmdlets used and their documentation:
    - Remove-MailboxPermission: https://learn.microsoft.com/en-us/powershell/module/exchangepowershell/remove-mailboxpermission?view=exchange-ps
    - Remove-RecipientPermission: https://learn.microsoft.com/en-us/powershell/module/exchangepowershell/remove-recipientpermission?view=exchange-ps
#>

$config = Import-PowershellDataFile -Path .\mstenant.psd1
$tenant = $config.domain

$userName = Read-Host "Username"
$sharedMailbox = Read-Host "Shared Mailbox"

$MailboxPermission = @{
    Identity = "$sharedMailbox@$tenant"
    User = "$userName@$tenant"
    AccessRights = "FullAccess"
    Confirm = $False
}
$RecipientPermission = @{
    Identity = "$sharedMailbox@$tenant"
    Trustee = "$userName@$tenant"
    AccessRights = "SendAs"
    Confirm = $False
}
Remove-MailboxPermission @MailboxPermission
Remove-RecipientPermission @RecipientPermission
