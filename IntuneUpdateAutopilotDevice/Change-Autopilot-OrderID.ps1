<#
.SYNOPSIS
    This script can update the Windows Autopilot Attributes "groupTag" and "orderIdentifier".
.DESCRIPTION
    The script fetches all registered Autopilot devices and display them in a Out-GridView. For the selected device the attributes will be updated.
.EXAMPLE
    "Invoke-MSGraphRequest : 405 Method Not Allowed
    {
    "error": {
        "code": "UnknownError",
        "message": "Method not allowed",
        "innerError": {
        "request-id": "6db731fb-3493-4873-9722-898500bb0c1b",
        "date": "2019-10-19T12:01:13"
        }
    }
    }"

    Currently returns "405 Method Not Allowed" but should be allowed with next Intune release
.EXAMPLE

    Todo 
.NOTES

.LINK
    
#>


$null = Connect-MSGraph
#$null = Update-MSGraphEnvironment -SchemaVersion "Beta"
$null = Connect-MSGraph

$autopilotDevices = Invoke-MSGraphRequest -HttpMethod GET -Url "deviceManagement/windowsAutopilotDeviceIdentities"

#display gridview to show devices

$selectedAutopilotDevice =  $autopilotDevices.value | Out-GridView -OutputMode Single

$selectedAutopilotDevice = Invoke-MSGraphRequest -HttpMethod GET -Url "deviceManagement/windowsAutopilotDeviceIdentities/$($selectedAutopilotDevice.id)"

$selectedAutopilotDevice.groupTag = "mOSD"
$selectedAutopilotDevice.orderIdentifier = "mOSD"

$selectedAutopilotDevice | Add-Member -Name '@odata.type' -Value "#microsoft.graph.windowsAutopilotDeviceIdentity" -MemberType NoteProperty

$jsonContent = $selectedAutopilotDevice | ConvertTo-Json

Invoke-MSGraphRequest -HttpMethod Patch -Url "deviceManagement/windowsAutopilotDeviceIdentities/$($selectedAutopilotDevice.id)" -Content $jsonContent -Verbose
