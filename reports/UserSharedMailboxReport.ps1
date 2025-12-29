<#
.SYNOPSIS
    Audit user shared mailbox membership

.DESCRIPTION
    Script is used to report what Microsoft 365 shared mailboxes the user
    currently has access to.

.AUTHOR
    Kevin Wilkins
    kwilkinsrd@gmail.com

.CREATED
    03/12/2025

.VERSION
    0.1.0

.NOTES
    Cmdlets used and their documentation:
    - Get-MailBox: https://learn.microsoft.com/en-us/powershell/module/exchangepowershell/get-mailbox?view=exchange-ps
    - Get-MailboxPermission: https://learn.microsoft.com/en-us/powershell/module/exchangepowershell/get-mailboxpermission?view=exchange-ps
    - Get-RecipientPermission: https://learn.microsoft.com/en-us/powershell/module/exchangepowershell/get-recipientpermission?view=exchange-ps
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

$userName = Read-Host "Username to search"
$sharedMailboxes = Get-Mailbox -RecipientTypeDetails SharedMailbox -ResultSize Unlimited

$results = foreach ($mailbox in $sharedMailboxes) {
    $MailboxPermission = @{
        Identity = $mailbox.UserPrincipalName
        User = "$userName@$tenant"
    }
    $RecipientPermission = @{
        Identity = $mailbox.UserPrincipalName
        Trustee = "$userName@$tenant"
    }

    $mailboxPermissions = Get-MailboxPermission @MailboxPermission
    $recipientPermissions = Get-RecipientPermission @RecipientPermission
    foreach ($permission in $mailboxPermissions) {
        [PSCustomObject]@{
            SharedMailbox = $mailbox.UserPrincipalName
            UserEmail = $permission.User
            AccessRights = $permission.AccessRights
        }
    }
    foreach ($permission in $recipientPermissions) {
        [PSCustomObject]@{
            SharedMailbox = $mailbox.UserPrincipalName
            UserEmail = $permission.Trustee
            AccessRights = $permission.AccessRights
        }
    }
}
$results | Format-Table -AutoSize

Disconnect-ExchangeOnline -Confirm:$false
Write-Output "Disconnected from Microsoft Exchange Online."
