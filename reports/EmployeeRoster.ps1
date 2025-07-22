<#
Author: Kevin Wilkins
Date: 07/22/2025
Description:
This will gather all employee data within the Microsoft tenant
and export as a CSV file.
#>

$graphScopes = @(
    "User.Read.All"
)
$ConnectMgGraph = @{
    Scopes = $graphScopes
}
Connect-MgGraph @ConnectMgGraph
Write-Host -ForegroundColor Green "Connected to Microsoft Graph"

if ($IsLinux) {
    $csvPath = "/home/$([System.Environment]::UserName)/Downloads"
} elseif ($IsWindows) {
    $csvPath = "$HOME\Downloads"
} elseif ($IsMacOS) {
    $csvPath = "/Users/$([System.Environment]::UserName)/Downloads"
} else {
    Write-Host "OS is not supported by this script"
}
$csvFile = "EmployeeRoster.csv"

$mgUser = @{
    All = $true
    Property = "DisplayName","UserPrincipalName","Department","JobTitle"
}
$select = @{
    Property = "DisplayName","UserPrincipalName","Department","JobTitle"
}
$export = @{
    Path = "$csvPath/$csvFile"
    NoTypeInformation = $true
    Encoding = "UTF8"
}

Get-MgUser @mgUser | Select-Object @select | Export-Csv @export

Disconnect-MgGraph
Write-Host -ForegroundColor Red "Disconnected from Microsoft Graph."
