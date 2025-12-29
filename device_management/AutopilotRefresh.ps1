<#
.SYNOPSIS
    Fresh start Autopilot device

.DESCRIPTION
    Script will run the Autopilot fresh start command on a device based on serial number lookup.

.AUTHOR
    Kevin Wilkins
    kwilkinsrd@gmail.com

.CREATED
    11/24/2025

.VERSION
    0.1.0

.NOTES
    Cmdlets used and their documentation:
    - Get-MgDeviceManagementManagedDevice: https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.devicemanagement/get-mgdevicemanagementmanageddevice?view=graph-powershell-1.0
    - Invoke-MgGraphRequest: https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.authentication/invoke-mggraphrequest?view=graph-powershell-1.0
#>

# Connect to Microsoft Graph to interact with Microsoft Intune scoped
# to handle gathering device info and performing the Autopilot Refresh.
$graphScopes = @(
    "DeviceManagementManagedDevices.ReadWrite.All",
    "DeviceManagementManagedDevices.PrivilegedOperations.All"
)
$ConnectMgGraph = @{
    Scopes = $graphScopes
}
Connect-MgGraph @ConnectMgGraph
Write-Output "Connected to Microsoft Graph."

# Search and confirm device exists in Intune.
$deviceSearch = Read-Host "Device to be reset:"
$device = Get-MgDeviceManagementManagedDevice -Filter "contains(deviceName,'$deviceSearch')"
if ($device.Count -eq 0) {
    Write-Output "No device found matching $deviceSearch"
    exit
} else {
    Write-Output "Device found:"
    $device | Select-Object Id,DeviceName,SerialNumber
}

# Send command to Autopilot reset using wipe method. Wipe method should be configured to
# allow keeping device enrolled in Intune.
$uri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices/$($device.Id)/wipe"
$body = @{
    keepEnrollmentData = $false
    keepUserData = $false
    useProtectedWipe = $false
} | ConvertTo-Json
Invoke-MgGraphRequest -Method POST -Uri $uri -Body $body -ContentType "application/json"

# Disconnect from Microsoft Graph when done.
Disconnect-MgGraph
Write-Output "Disconnected from Microsoft Graph."
