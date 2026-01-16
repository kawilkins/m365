<#
.SYNOPSIS
    Remove a user from Microsoft

.DESCRIPTION
    Script will remove a user from Microsoft.
    This will involve performing the following tasks in sequence:

        1. Roll password to random generated password.
        2. Disable the user.
        3. Revoke any current sign in sessions.
        4. Remove user from distribution groups and shared mailboxes
        5. Remove user from any Microsoft groups - including security groups.
        6. Remove any licenses from the user.
        7. Remove the user from Microsoft.

.AUTHOR
    Kevin Wilkins
    kwilkinsrd@gmail.com

.CREATED
    12/17/2025

.VERSION
    0.1.0

.NOTES
    Script will required both Microsoft Graph and ExchangeOnline modules.

    Cmdlet used and their documentation:
    - Remove-DistributionGroupMember: https://learn.microsoft.com/en-us/powershell/module/exchangepowershell/remove-distributiongroupmember?view=exchange-ps
    - Update-MgUser: https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.users/update-mguser?view=graph-powershell-1.0
#>

# Import tenant information from the PowerShell Data file.
$config = Import-PowershellDataFile -Path .\mstenant.psd1
$tenant = $config.domain

# Connect to Exchange Online
$adminUser = Read-Host "Admin username"
$exchangeonline = @{
    UserPrincipalName = "${adminUser}@${tenant}"
    ShowBanner = $false
}
Connect-ExchangeOnline @exchangeonline
Write-Output "Connected to Microsoft ExchangeOnline."

# Connect to Microsoft Graph
$graphScopes = @(
    "User.ReadWrite.All",
    "Group.ReadWrite.All",
    "Directory.ReadWrite.All",
    "Directory.AccessAsUser.All",
    "User.ManageIdentities.All",
    "GroupMember.ReadWrite.All"
)
$ConnectMgGraph = @{
    Scopes = $graphScopes
}
Connect-MgGraph @ConnectMgGraph
Write-Output "Connected to Microsoft Graph."

# Get User
$userName = Read-Host "User to be removed"
$member = "${userName}@${tenant}"
$user = Get-MgUser -UserId $member

# Roll user password
# Disable user
# Force signout user
function RandomPassword {
    $uppercase = 65..90 | ForEach-Object { [char]$_ }
    $lowercase = 97..122 | ForEach-Object { [char]$_ }
    $number    = 48..57 | ForEach-Object { [char]$_ }

    $requiredChars = @(
        $uppercase | Get-Random
        $lowercase | Get-Random
        $number | Get-Random
    )

    $allChars = $uppercase + $lowercase + $number
    $randomChars = 1..9 | ForEach-Object { $allChars | Get-Random }

    return -join ($requiredChars + $randomChars | Get-Random -Count 12)
}

$passwordProfile = @{
    ForceChangePasswordNextSignIn = $True
    Password = RandomPassword
}
$UpdateMgUser = @{
    UserId = "$member"
    PasswordProfile = $passwordProfile
    AccountEnabled = $false
}
Write-Output "Resetting password for $userName"
Update-MgUser @UpdateMgUser
Write-Output "Signing out user from all sessions."
Revoke-MgUserSignInSession -UserId "$member"

# Remove user from Distribution Lists
$distributionLists = Get-DistributionGroup -ResultSize Unlimited | Where-Object {
    (Get-DistributionGroupMember $_.Identity -ResultSize Unlimited).PrimarySmtpAddress -contains "$userName"
}
foreach ($distributionList in $distributionLists) {
    Write-Output "Removing $userName from $($distributionList.DisplayName)"
    $RemoveDistributionGroupMember = @{
        Identity = $distributionList.Identity
        Member = "$member"
        Confirm = $false
    }
    Remove-DistributionGroupMember @RemoveDistributionGroupMember
}

# Remove user from Shared Mailboxes
$SharedMailbox = Get-Mailbox -RecipientTypeDetails SharedMailbox -ResultSize Unlimited | Where-Object {
    (Get-MailboxPermission $_.PrimarySmtpAddress | Where-Object {
        $_.User -eq $member -and $_.AccessRights -ne "None"
    })
}
foreach ($mailbox in $SharedMailbox) {
    Write-Output "Removing $userName from $($mailbox.PrimarySmtpAddress)"
    $MailboxPermission = @{
        Identity = $mailbox.PrimarySmtpAddress
        User = "$member"
        AccessRights = "FullAccess"
        Confirm = $False
    }
    $RecipientPermission = @{
        Identity = $mailbox.PrimarySmtpAddress
        Trustee = "$member"
        AccessRights = "SendAs"
        Confirm = $False
    }
    Remove-MailboxPermission @MailboxPermission
    Remove-RecipientPermission @RecipientPermission
}

# Remove user from Microsoft groups
$groups = Get-MgUserMemberOf -UserId $member
foreach ($group in $groups) {
    if ($group.AdditionalProperties['mailEnabled'] -eq $true -and $group.AdditionalProperties['securityEnabled'] -eq $false) { continue }
    if ($group.AdditionalProperties['isAssignableToRole'] -eq $true) { continue }
    if ($group.AdditionalProperties['groupTypes'] -contains 'Unified') { continue }
    Write-Output "Removing $userName from $group.DisplayName)"
    $RemoveMgGroupMember = @{
        GroupId = $group.Id
        DirectoryObjectId = $user.Id
    }
    Remove-MgGroupMemberByRef @RemoveMgGroupMember
}

# Remove any licenses from the user
$license = @($user.AssignedLicenses.SkuId) | Where-Object { $_ -and $_ -ne "" }
if ($license.Count -gt 0) {
    $MgUserLicense = @{
        UserId = $user.Id
        AddLicenses = @()
        RemoveLicenses = $license
    }
    Write-Output "Removing licenses for $userName"
    Set-MgUserLicense @MgUserLicense
} else {
    Write-Output "$userName has no licenses to remove."
}

# Remove the user from Microsoft
Write-Output "Removing $userName from Microsoft."
Remove-MgUser -UserId "$member"

# Disconnect from Exchange Online and Microsoft Graph.
Disconnect-ExchangeOnline -Confirm:$false
Write-Output "Disconnected from Microsoft Exchange Online."
Disconnect-MgGraph | Out-Null
Write-Output "Disconnected from Microsoft Graph."
