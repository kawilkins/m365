<#
.SYNOPSIS
    Connect to Microsoft Graph.

.DESCRIPTION
    Script will authenticate and connect to Microsoft Intune via
    the Microsoft Graph module.

.AUTHOR
    Kevin Wilkins
    kwilkinsrd@gmail.com

.CREATED
    07/14/2025

.VERSION
    0.1.0

.NOTES
    Cmdlets used and their documentation:
    - Connect-MgGraph: https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.authentication/connect-mggraph?view=graph-powershell-1.0
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
