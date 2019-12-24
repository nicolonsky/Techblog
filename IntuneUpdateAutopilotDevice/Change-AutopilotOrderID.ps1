Connect-MSGraph
Update-MSGraphEnvironment -SchemaVersion "Beta" -Quiet
Connect-MSGraph -Quiet

# Get all autopilot devices (even if more than 1000)
$autopilotDevices = Invoke-MSGraphRequest -HttpMethod GET -Url "deviceManagement/windowsAutopilotDeviceIdentities"
$autopilotDevices = $autopilotDevices | Get-MSGraphAllPages

# Display gridview to show devices
$selectedAutopilotDevices =  $allAutopilotDevices | Out-GridView -OutputMode Multiple -Title "Select Windows Autopilot entities to update"

$selectedAutopilotDevices | ForEach-Object {

    Write-Output "Updating entity: $($PSItem.id)"

    # Change names according to your environment
    $PSItem.groupTag = "mOSD"
    #$PSItem.orderIdentifier = "mOSD"

    Invoke-MSGraphRequest -HttpMethod POST -Url "deviceManagement/windowsAutopilotDeviceIdentities/$($PSItem.id)/UpdateDeviceProperties" -Content $PSItem -Verbose
}

# Invoke a autopilot service sync
Invoke-MSGraphRequest -HttpMethod POST -Url "deviceManagement/windowsAutopilotSettings/sync"