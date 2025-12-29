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
    - Disconnect-MgGraph: https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.authentication/disconnect-mggraph?view=graph-powershell-1.0
#>

Disconnect-MgGraph
Write-Output "Disconnected from Microsoft Graph."
