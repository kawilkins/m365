<#
.SYNOPSIS
    Updates user information in Microsoft Intune.

.DESCRIPTION
    Script imports a CSV file containing user information and then
    updates each user's information in Intune using Microsoft Graph.

.AUTHOR
    Kevin Wilkins
    kwilkinsrd@gmail.com

.CREATED
    06/10/2025

.VERSION
    0.1.0

.NOTES
    Cmdlets used and their documentation:
    - Update-MgUser: https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.users/update-mguser
#>

$config = Import-PowershellDataFile -Path .\mstenant.psd1
$tenant = $config.domain
$users = Import-Csv -Path .\user.csv
$counter = 0
$totalUsers = $users.Count

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

foreach ($user in $users) {
    $counter++
    $completion = ($counter / $totalUsers) * 100

    $WriteProgress = @{
        Activity = "Updating User Data"
        Status = "Processing user $($user.UserName)@$tenant"
        PercentComplete = $completion
        CurrentOperation = "User $counter of $totalUsers"
    }
    $properties = @{
        UserId = "$($user.UserName)@$tenant"
        Department = $user.Department
        JobTitle = $user.JobTitle
        BusinessPhones = $user.BusinessPhones
        OfficeLocation = $user.OfficeLocation
    }
    Update-MgUser @properties
    Write-Progress @WriteProgress
}

Write-Progress -Activity "Updating User Data" -Completed

Disconnect-MgGraph
Write-Output "Disconnected to Microsoft Graph."
