<#
Author: Kevin Wilkins
Date: 02/19/2025
Description:
This script will reset a users password and force a password change at next
sign in.
#>

$config = Import-PowershellDataFile -Path .\mstenant.psd1
$tenant = $config.domain

$userName = Read-Host "Username: "
$passwd = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 12 | ForEach-Object {[char]$_})

Update-MgUser `
    -UserId "$userName@$tenant" `
    -PasswordProfile @{
        ForceChangePasswordNextSignIn = $True;
        Password = "$passwd"
    } `

Write-Host @"
Password changed for $userName.

New password: $password

"@
