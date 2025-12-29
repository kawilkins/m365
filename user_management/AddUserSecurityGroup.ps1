<#
.SYNOPSIS
    Adds user to a security group

.DESCRIPTION
    Script will add a user to a security group.
    Script originally developed for testing ability to assign a user to a Microsoft Security Group.
    For testing used the 'KnowBe4 Provisioning' security group.

.AUTHOR
    Kevin Wilkins
    kwilkinsrd@gmail.com

.CREATED
    09/11/2025

.VERSION
    0.1.0

.NOTES
    For the varialble 'secgrp' please be aware that the "SecurityGroup" heading in
    'user.csv' is not present and will need to be added if used.
    Cmdlets used and their documentation:
    - New-GroupMemberByRef: https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.groups/new-groupmemberbyref
#>

$userData = ".\user.csv"
$users = Import-Csv -Path $userData
$config = Import-PowershellDataFile -Path .\mstenant.psd1
$tenant = $config.domain

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

foreach ($user in $users) {
    $secgrp = Get-MgGroup -Filter "displayName eq '$($user.SecurityGroup)'"
    $member = Get-MgUser -Filter "userPrincipalName eq '$($user.UserName)@$tenant'"

    $body = @{
        "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($member.Id)"
    }
    New-MgGroupMemberByRef -GroupId $secgrp.Id -BodyParameter $body
}

Disconnect-MgGraph
Write-Output "Disconnected from Microsoft Graph."
