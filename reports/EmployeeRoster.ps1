<#
.SYNOPSIS
    Export user data to CSV.

.DESCRIPTION
    Script will gather all employee user data and export into a CSV.
    Script will detect if PowerShell is running on Windows, Linux, or MacOS and
    export the CSV to the users "Downloads" directory.

.AUTHOR
    Kevin Wilkins
    kwilkinsrd@gmail.com

.CREATED
    07/22/2025

.VERSION
    0.1.0

.NOTES
    Cmdlets used and their documentation.
    - Get-MgUser: https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.users/get-mguser?view=graph-powershell-1.0
#>

$graphScopes = @(
    "User.Read.All"
)
$ConnectMgGraph = @{
    Scopes = $graphScopes
}
Connect-MgGraph @ConnectMgGraph
Write-Output "Connected to Microsoft Graph"

if ($IsLinux) {
    $csvPath = "/home/$([System.Environment]::UserName)/Downloads"
} elseif ($IsWindows) {
    $csvPath = "$HOME\Downloads"
} elseif ($IsMacOS) {
    $csvPath = "/Users/$([System.Environment]::UserName)/Downloads"
} else {
    Write-Output "OS is not supported by this script"
}
$csvFile = "EmployeeRoster.csv"

$mgUser = @{
    All = $true
    Filter = "userType eq 'Member' and accountEnabled eq true"
    Property = "DisplayName","UserPrincipalName","Department","JobTitle","BusinessPhones","OfficeLocation","StreetAddress","City","PostalCode","UserType","AccountEnabled"
}
$select = @{
    Property = "DisplayName","UserPrincipalName","Department","JobTitle",@{Name="BusinessPhones";Expression={$_.BusinessPhones -join ";"}},"OfficeLocation","StreetAddress","City","PostalCode"
}
$export = @{
    Path = "$csvPath/$csvFile"
    NoTypeInformation = $true
    Encoding = "UTF8"
}
Get-MgUser @mgUser | Where-Object { $_.Department } | Sort-Object DisplayName | Select-Object @select | Export-Csv @export

Disconnect-MgGraph
Write-Output "Disconnected from Microsoft Graph."
