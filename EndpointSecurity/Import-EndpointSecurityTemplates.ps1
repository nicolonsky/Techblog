#Requires -Module MSAL.PS

[CmdletBinding()]
param (
    [Parameter()]
    [string]
    [ValidateScript( { Test-Path $_ -PathType Container })]
    $TemplatePath = (Join-Path $PSScriptRoot "EndpointSecurityExport")
)

function Import-EndpointSecurityConfiguration {
    [CmdletBinding()]
    param (
        [Parameter()]
        [psobject]
        $Configuration
    )

    process {
        # build request url and remove templateId
        $requestUrl = "$script:graphUrl/templates/$($Configuration.templateId)/createInstance"
        $Configuration.PSObject.properties.remove('templateId')

        #convert config to hashtable
        $requestBody = @{}
        foreach ($property in  $Configuration.PSObject.properties) {
            $requestBody.Add($property.Name, $property.Value)
        }

        if ($null -eq $requestBody.description) {
            $requestBody.description = ""
        }

        $body = $requestBody | ConvertTo-Json -Depth 5
        Invoke-RestMethod -Uri $requestUrl -Method Post -Body $body -Headers $script:authHeader -ContentType "application/json"
    }
}

# Use built in Microsoft Intune Powershell app
# If you're on PowerShell 7 you need to use device code flow or a custom app registration
$params = @{
    ClientId   = "d1ddf0e4-d672-4dae-b554-9d5bdfd93547"
    DeviceCode = $true
}

#base url for requests
$script:graphUrl = "https://graph.microsoft.com/beta/deviceManagement"

# verify token
if (-not ($token -and $token.ExpiresOn.LocalDateTime -ge $(Get-Date))) {
    $token = Get-MsalToken @params
}

#auth header used to pass the access token
$script:authHeader = @{
    'Authorization' = $token.CreateAuthorizationHeader()
}

# fetch exported templates
$templates = Get-ChildItem -Path $TemplatePath -ErrorAction Stop

# import
foreach ($template in $templates) {
    $config = Get-Content -Path $template.FullName | ConvertFrom-Json
    Write-Output "Import $($config.displayName)..."
    Import-EndpointSecurityConfiguration -Configuration $config
}