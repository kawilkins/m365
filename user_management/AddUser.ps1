<#
.SYNOPSIS
    Adds new Microsoft 365 users with mailboxes using data from a CSV file.

.DESCRIPTION
    This script reads a CSV file containing user information and creates multiple Microsoft 365 users.
    Each user is assigned the following:
     1. Random generated password for one time use during onboarding
     2. Any distribution groups needed during onboarding
     3. Any security groups needed during onboarding
     4. Update employee information in Microsoft

.AUTHOR
    Kevin Wilkins
    kwilkinsrd@gmail.com

.CREATED
    06/24/2024

.VERSION
   1.2.0

.NOTES
    Cmdlets used and their documentation:
    - New-Mailbox: https://learn.microsoft.com/en-us/powershell/module/exchange/new-mailbox
    - Add-DistributionGroupMember: https://learn.microsoft.com/en-us/powershell/module/exchangepowershell/add-distributiongroupmember?view=exchange-ps
    - Update-MgUser: https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.users/update-mguser
    - New-GroupMemberByRef: https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.groups/new-groupmemberbyref
    - Invoke-MgGraphRequest: https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.authentication/invoke-mggraphrequest?view=graph-powershell-1.0

    Ensure the CSV file is properly formatted with required fields before running the script.
#>

# Import user data and Microsoft tenant information.
$userData = ".\user.csv"
$users = Import-Csv -Path $userData
$config = Import-PowershellDataFile -Path .\mstenant.psd1
$tenant = $config.domain

# Connect to Exchange Online to interact with Microsoft 365 and
# suppress welcome banner. Exchangeonline will require authentication
# via username and password to verify if user can perform the
# operations contained in the script.
$admin_user = Read-Host "Admin username"
$exchangeonline = @{
    UserPrincipalName = "$admin_user@$tenant"
    ShowBanner = $false
}
Connect-ExchangeOnline @exchangeonline
Write-Output "Connected to Microsoft ExchangeOnline."

# Connect to Microsoft Graph to interact with Microsoft Intune scoped
# to handle writing information to users and adding to security groups.
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
    NoWelcome = $true
}
Connect-MgGraph @ConnectMgGraph
Write-Output "Connected to Microsoft Graph."

# Set security groups for each user to be added to.
function Add-UserToSecurityGroup {
    param(
        [Parameter(Mandatory)]
        $User,

        [Parameter(Mandatory)]
        [string]$Tenant
    )

    # List security groups on each line ending each line with a ","
    $security_groups = @(
    )
    $member = Get-MgUser -Filter "userPrincipalName eq '$($User.UserName)@$Tenant'"
    $body = @{
        "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($member.Id)"
    }

    foreach ($secgrp in $security_groups) {
        $group = Get-MgGroup -Filter "displayName eq '$secgrp'"
        New-MgGroupMemberByRef -GroupId $group.Id -BodyParameter $body
    }
}

# Set distribution groups for each user to be added to
function Add-UserToDistributionGroup {
    param (
        [Parameter(Mandatory)]
        $User,

        [Parameter(Mandatory)]
        [string]$Tenant
    )

    # List distribution groups on each line ending each line with a ",".
    $distribution_groups = @(
    )

    foreach ($dl in $distribution_groups) {
        $AddDistributionGroupMember = @{
            Identity = "$dl@$Tenant"
            Member = "$($User.UserName)@$Tenant"
        }
        Add-DistributionGroupMember @AddDistributionGroupMember
    }
}

# Iterate each row in the CSV to extrapolate user information. This
# information will be used to create each user.
foreach ($user in $users) {
    $firstName = $user.FirstName
    $lastName = $user.LastName
    $userName = $user.UserName
    $email = "$userName@$tenant"

    # Assign a random generated password containing at least
    # 1 Uppercase letter
    # 1 Lowercase letter
    # 1 Number
    function RandomPassword {
        $uppercase = 65..90 | ForEach-Object { [char]$_ }
        $lowercase = 97..122 | ForEach-Object { [char]$_ }
        $number    = 48..57 | ForEach-Object { [char]$_ }

        $requiredChars = @(
            $uppercase | Get-Random
            $lowercase | Get-Random
            $number | Get-Random
        )

        $allChars = $uppercase + $lowercase + $number
        $randomChars = 1..9 | ForEach-Object { $allChars | Get-Random }

        return -join ($requiredChars + $randomChars | Get-Random -Count 12)
    }
    $passwd = RandomPassword

    # Create the new mailbox using the user information as above
    $NewMailbox = @{
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
    New-Mailbox @NewMailbox

    #Assign user to distribution groups.
    $AddUserToDistributionGroup = @{
        User = $user
        Tenant = $tenant
    }
    Add-UserToDistributionGroup @AddUserToDistributionGroup

    # Add sleep timer to give Exchange time to sync to Intune
    Start-Sleep -Seconds 15

    # Add user department, job title, and phone number
    $properties = @{
        UserId = "$email"
        Department = $user.Department
        JobTitle = $user.JobTitle
        BusinessPhones = $user.BusinessPhones
        OfficeLocation = $user.OfficeLocation
    }
    Update-MgUser @properties

    # Set user location to their office location.
    $location = @{
        streetAddress = "$($user.StreetAddress)"
        city = "$($user.City)"
        state = "$($user.State)"
        postalCode = "$($user.PostalCode)"
    } | ConvertTo-Json -Depth 3
    $MgGraphRequest = @{
        Method = "PATCH"
        Uri = "https://graph.microsoft.com/v1.0/users/$($user.UserName)@$tenant"
        Body = $location
    }
    Invoke-MgGraphRequest @MgGraphRequest

    # Add users to security groups
    $AddUserToSecurityGroup = @{
        User = $user
        Tenant = $tenant
    }
    Add-UserToSecurityGroup @AddUserToSecurityGroup

    # For security purposes disable the newly created user prior to their start date.
    Write-Output "Disabling $userName"
    $UpdateMgUser = @{
        UserId = "$userName@$tenant"
        AccountEnabled = $false
    }
    Update-MgUser @UpdateMgUser

    Write-Output "Signing out $userName from all sessions."
    Revoke-MgUserSignInSession -UserId "$userName@$tenant" | Out-Null

    # Verify that user has been disabled.
    Start-Sleep -Seconds 5
    $newUser = Get-MgUser -UserId $userName@$tenant -Property AccountEnabled
    if ($newUser.AccountEnabled -eq $false) {
        Write-Output "$userName is DISABLED."
    } else {
        Write-Output "$userName is ENABLED."
    }

    # Write output to the console for confirmation that the user was created and
    # generate a 'txt' file for easy copy/paste.
    $output = @{
        Content = "`n$firstName $lastName`nEmail: $email`nPassword: $passwd`n"
    }
    $output.Content | Out-File -FilePath "created_user.txt" -Encoding UTF8 -Append
}

# Disconnect from Exchange Online and Microsoft Graph.
Disconnect-ExchangeOnline -Confirm:$false
Write-Output "Disconnected from Microsoft Exchange Online."
Disconnect-MgGraph | Out-Null
Write-Output "Disconnected from Microsoft Graph."
