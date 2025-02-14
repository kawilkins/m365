<#
Author: Kevin Wilkins
Date: 02/14/2025
Description: 
This script will install and import Exchange Online PowerShell
and Microsoft Graph modules.

Be sure to have your Execution Policy set.

Set-ExecutionPolicy -ExecutionPolicy bypass
#>

Install-Module -Name ExchangeOnline -Scope CurrentUser
Install-Module Microsoft.Graph -Scope CurrentUser -Repository PSGallery -Force

Import-Module ExchangeOnlineManagement
