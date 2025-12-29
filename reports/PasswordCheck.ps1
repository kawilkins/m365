<#
.SYNOPSIS
    Check age of password.

.DESCRIPTION
    Script will check the last time all users have changed their password.
    Output is exported to a CSV that is saved to the users 'Downloads' directory
    after checking if PowerShell is running on Windows, Linux, or MacOS.

.AUTHOR
    Kevin Wilkins
kwilkinsrd@gmail.com

.CREATED
    02/10/2025

.VERSION
    0.1.0

.NOTES
    Cmdlets used and their documentation:
    - Get-MgUser: https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.users/get-mguser?view=graph-powershell-1.0
#>

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
Write-Output "Connected to Microsoft Graph."

if ($IsLinux) {
    $csvPath = "/home/$([System.Environment]::UserName)/Downloads"
} elseif ($IsWindows) {
    $csvPath = "$HOME\Downloads"
} elseif ($IsMacOS) {
    $csvPath = "/Users/$([System.Environment]::UserName)/Downloads"
} else {
    Write-Output "OS is not supported by this script"
}
$csvFile = "UserLastPasswordChange.csv"

$mgUser = @{
    All = $true
    Property = "DisplayName", "UserPrincipalName", "LastPasswordChangeDateTime"
}
$select = @{
    Property = "DisplayName", "UserPrincipalName", "LastPasswordChangeDateTime"
}
$sort = @{
    Property = "LastPasswordChangeDateTime"
    Descending = $true
}
$export = @{
    Path = "$csvPath/$csvFile"
    NoTypeInformation = $true
    Encoding = "UTF8"
}
Get-MgUser @mgUser | Select-Object @select | Sort-Object @sort | Export-Csv @export

Disconnect-MgGraph
Write-Output "Disconnected from Microsoft Graph."
