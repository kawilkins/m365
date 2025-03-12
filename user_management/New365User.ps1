<#
Author: Kevin Wilkins
Date: 06/24/2024
Description: 
This script will add a new Microsoft 365 user with mailbox.
A random password to be given to the new user will be
generated and the output to the screen. The script will
iterate over a CSV file so that multiple users can be
created at once.
#>

$userData = ".\new365user.csv"
$users = Import-Csv -Path $userData
$config = Import-PowershellDataFile -Path .\mstenant.psd1
$tenant = $config.domain

foreach ($user in $users) {
    $firstName = $user.FirstName
    $lastName = $user.LastName
    $userName = $user.UserName
    $email = "$userName@$tenant"
    $passwd = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 10 | ForEach-Object {[char]$_})

    $params = @{
        Name = $userName
        Alias = $userName
        FirstName = $firstName
        LastName = $lastName
        DisplayName = "$firstName $lastName"
        MicrosoftOnlineServicesID = $email
        PrimarySmtpAddress = $email
        Password = (ConvertTo-SecureString -String $passwd -AsPlainText -Force)
        ResetPasswordOnNextLogon = $true
    }
    $output = @{
        Content = "`n$firstName $lastName`nEmail: $email`nPassword: $passwd`n"
    }

    New-Mailbox @params -WhatIf
    Write-Host $output.Content
}
