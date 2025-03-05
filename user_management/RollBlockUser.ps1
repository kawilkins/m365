<#
Author: Kevin Wilkins
Date: 03/05/2025
Description:
This script will prompt for the username of a user and then do the
following:

- Roll user password
- Block user from signing in to Microsoft
- Revoke current signins from user

This can be used in an emergency where a user account is compromised.
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
    -AccountEnabled $false

Revoke-MgUserSignInSession -UserId "$userName@$tenant"
