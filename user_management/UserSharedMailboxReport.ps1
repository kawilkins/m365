<#
Author: Kevin Wilkins
Date: 03/12/2025
Description:
This script is used to audit the current shared mailboxes available for a
selected user.

Input is the username which will be used to pull the permissions for each
shared mailbox that the user has permission to have access to.
#>

$config = Import-PowershellDataFile -Path .\mstenant.psd1
$tenant = $config.domain
$userName = Read-Host "Username to search"
$sharedMailboxes = Get-Mailbox -RecipientTypeDetails SharedMailbox -ResultSize Unlimited

$results = foreach ($mailbox in $sharedMailboxes) {
    $mailboxParams = @{
        Identity = $mailbox.UserPrincipalName
        User = "$userName@$tenant"
    }
    $recipientParams = @{
        Identity = $mailbox.UserPrincipalName
        Trustee = "$userName@$tenant"
    }

    $mailboxPermissions = Get-MailboxPermission @mailboxParams
    $recipientPermissions = Get-RecipientPermission @recipientParams
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
