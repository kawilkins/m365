<#
.SYNOPSIS
    Disable user.

.DESCRIPTION
    Disable a user in Microsoft.
    Script will prompt for a username and then do the following:
        1. Block user from signing into their Microsoft account
        2. Revoke current user sessions currently associated with the user
    
    Script can be used for disabling an exiting employee, or responding to
    a compromised user account.

.AUTHOR
    Kevin Wilkins
    kwilkinsrd@gmail.com

.CREATED
    03/05/2025

.VERSION
    0.1.0

.NOTES
    Cmdlets used and their documentation:
    - Update-MgUser: https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.users/update-mguser?view=graph-powershell-1.0
    - Revoke-MgUserSignInSession: https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.users.actions/revoke-mgusersigninsession?view=graph-powershell-1.0
#>

$config = Import-PowershellDataFile -Path .\mstenant.psd1
$tenant = $config.domain

$graphScopes = @(
    "User.ReadWrite.All",
    "Group.ReadWrite.All",
    "Directory.ReadWrite.All",
    "Directory.AccessAsUser.All",
    "User.ManageIdentities.All"
)
$ConnectMgGraph = @{
    Scopes = $graphScopes
}
Connect-MgGraph @ConnectMgGraph
Write-Host -ForegroundColor Green "Connected to Microsoft Graph."

$userName = Read-Host "Username"

$UpdateMgUser = @{
    UserId = "$username@$tenant"
    AccountEnabled = $false
}
Update-MgUser @UpdateMgUser
Revoke-MgUserSignInSession -UserId "$userName@$tenant"

Disconnect-MgGraph
Write-Output "Disconnected from Microsoft Graph."
