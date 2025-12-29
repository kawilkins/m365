<#
.SYNOPSIS
    Reset user password.

.DESCRIPTION
    Script will reset a user password and force a password change at the next
    time user signs in.

.AUTHOR
    Kevin Wilkins
    kwilkinsrd@gmail.com

.CREATED
    02/19/2025

.VERSION
    0.1.0

.NOTES
    Cmdlets used and their documentation:
    - Update-MgUser: https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.users/update-mguser?view=graph-powershell-1.0
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
Write-Output "Connected to Microsoft Graph."

$userName = Read-Host "Username"
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
$passwd = RandomPassword

$passwordProfile = @{
    ForceChangePasswordNextSignIn = $True
    Password = "$passwd"
}
$updateMgUser = @{
    UserId = "$username@$tenant"
    PasswordProfile = $passwordProfile
}
Update-MgUser @updateMgUser

$output = @{
    Content = "`nPassword changed for $userName`nPassword: $passwd`n"
}
Write-Host $output.Content

Disconnect-MgGraph
Write-Output "Disconnected from Microsoft Graph."
