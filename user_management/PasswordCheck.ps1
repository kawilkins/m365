<#
Author: Kevin Wilkins
Date: 02/10/2025
Description: 
Powershell script that checks the last time a password was updated.
Output is exported to a CSV file that is then stored in the users
Downloads directory.
#>

if ($IsLinux) {
    $csvPath = "/home/$([System.Environment]::UserName)/Downloads"
} elseif ($IsWindows) {
    $csvPath = "$HOME\Downloads"
} elseif ($IsMacOS) {
    $csvPath = "/Users/$([System.Environment]::UserName)/Downloads"
} else {
    Write-Host "OS is not supported by this script"
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
