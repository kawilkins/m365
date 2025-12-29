<#
.SYNOPSIS
    Adds new Microsoft 365 users with mailboxes using data from a CSV file.

.DESCRIPTION
    This script reads a CSV file containing user information and creates multiple Microsoft 365 users.
    Each user is assigned the following:
     1. Random generated password for one time use during onboarding
     2. All Socket distribution group for company-wide emails
     3. Crossware signature group for adding company branded signature to outgoing emails.
     4. KnowBe4 phishing training provisioning group
     5. Licensing group that will handle provisioning of Microsoft license

.AUTHOR
    Kevin Wilkins
    kwilkinsrd@gmail.com

.CREATED
    06/24/2024

.VERSION
   1.3.0

.NOTES
    Cmdlets used and their documentation:
    - New-Mailbox: https://learn.microsoft.com/en-us/powershell/module/exchange/new-mailbox
    - Add-DistributionGroupMember: https://learn.microsoft.com/en-us/powershell/module/exchangepowershell/add-distributiongroupmember?view=exchange-ps
    - Update-MgUser: https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.users/update-mguser
    - New-GroupMemberByRef: https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.groups/new-groupmemberbyref

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
$username = Read-Host "Username"
$exchangeonline = @{
    UserPrincipalName = "$username@$tenant"
    ShowBanner = $false
}
Connect-ExchangeOnline @exchangeonline
Write-Output "Connected to Microsoft ExchangeOnline."

# Connect to Microsoft Graph to interact with Microsoft Intune scoped
# to handle writing information to user objects and adding to 
# security groups.
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
}
Connect-MgGraph @ConnectMgGraph
Write-Output "Connected to Microsoft Graph."

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
    # and assign user to distribution group(s).
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

    $DistributionGroupMember = @{
        Identity = ""
        Member = "$email"
    }
    Add-DistributionGroupMember @DistributionGroupMember

    # Add sleep timer to give Exchange time to sync to Intune
    Start-Sleep -Seconds 10

    $properties = @{
        UserId = "$email"
        Department = $user.Department
        JobTitle = $user.JobTitle
        BusinessPhones = $user.BusinessPhones
        OfficeLocation = $user.OfficeLocation
    }
    Update-MgUser @properties

    # Add users to security groups
    $secgrp = Get-MgGroup -Filter "displayName eq '$($user.SecurityGroup)'"
    $member = Get-MgUser -Filter "userPrincipalName eq '$($user.UserName)@$tenant'"
    $body = @{
        "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($member.Id)"
    }
    New-MgGroupMemberByRef -GroupId $secgrp.Id -BodyParameter $body

    # Write output to a 'txt' file for easy copy/paste.
    $output.Content | Out-File -FilePath "created_user.txt" -Encoding UTF8 -Append
}

# Disconnect from Exchange Online and Microsoft Graph.
Disconnect-ExchangeOnline -Confirm:$false
Write-Output "Disconnected from Microsoft Exchange Online."
Disconnect-MgGraph
Write-Output "Disconnected from Microsoft Graph."
