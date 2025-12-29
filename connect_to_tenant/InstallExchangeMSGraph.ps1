<#
.SYNOPSIS
    Install ExchangeOnline and Microsoft Graph modules.

.DESCRIPTION
    Script will install both of these modules:
    1. ExchangeOnlineManagement
    2. Microsoft.Graph

    These modules are needed to interact with Microsoft 365 and
    Microsoft Intune via Powershell.

.AUTHOR
    Kevin Wilkins
    kwilkinsrd@gmail.com

.CREATED
    02/14/2025

.VERSION
    0.1.0

.NOTES
    Set your execution policy as follows:
    Set-ExecutionPolicy -ExecutionPolicy bypass
#>

Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser
Install-Module Microsoft.Graph -Scope CurrentUser -Repository PSGallery -Force

Import-Module ExchangeOnlineManagement
