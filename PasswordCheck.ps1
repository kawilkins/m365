# Powershell script that checks the last time a password was updated.
# Will need to make sure that Microsoft Graph is installed.
#
# Set-ExecutionPolicy -ExecutionPolicy bypass
# Install-Module Microsoft.Graph -Scope CurrentUser -Repository PSGallery

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

Get-MgUser -All -Property DisplayName, UserPrincipalName, LastPasswordChangeDateTime `
    | Select-Object -Property DisplayName,UserPrincipalName,LastPasswordChangeDateTime `
    | Sort-Object -Property LastPasswordChangeDateTime -Descending `
    | Export-Csv -Path $csvPath/$csvFile -NoTypeInformation -Encoding UTF8
