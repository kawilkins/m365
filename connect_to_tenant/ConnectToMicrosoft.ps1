<#
Author: Kevin Wilkins
Date: 02/12/2025
Description: 
Script that connects to Microsoft Exchange Online and Microsoft Graph.
User is prompted for their username which is a security feature to make
sure that the user signing in is verified by Microsoft as a valid
administrator.
#>

$config = Import-PowershellDataFile -Path .\mstenant.psd1
$tenant = $config.domain
$username = Read-Host "Username"

Connect-ExchangeOnline `
    -UserPrincipalName $username@$tenant

Connect-MgGraph -Scopes `
    "User.ReadWrite.All", `
    "Group.ReadWrite.All", `
    "LicenseAssignment.ReadWrite.All"
