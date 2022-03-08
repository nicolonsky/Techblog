#Requires -Module MSAL.PS

function Get-EndpointSecurityTemplate {
    [CmdletBinding()]
    param (
        # Id of the intent
        [Parameter(Mandatory = $false)]
        [guid]
        $Id
    )

    begin {
        $requestUrl = $graphUrl + "/intents"
        if ($PSBoundParameters.ContainsKey("Id")) {
            $requestUrl = $requestUrl + "/$Id"
        }
    }

    process {
        $templates = Invoke-RestMethod -Uri $requestUrl -Headers $script:authHeader
        return $templates
    }
}

function Get-EndpointSecurityConfiguration {
    [CmdletBinding()]
    param (
        # Id of the configuration
        [Parameter(Mandatory = $true)]
        [guid]
        $Id
    )

    begin {
        $requestUrl = $script:graphUrl + "/intents/$Id/settings"
    }

    process {
        $config = Invoke-RestMethod -Uri $requestUrl -Headers $script:authHeader
        return $config
    }
}

function Export-EndpointSecurityConfiguration {
    [CmdletBinding()]
    param (
        # Id of the configuration to export
        [Parameter(Mandatory = $true)]
        [guid]
        $Id
    )

    begin {
        # Exclude MDATP template because of onboarding blob
        $excludedTemplates = @("e44c2ca3-2f9a-400a-a113-6cc88efd773d")
    }

    process {

        $template = Get-EndpointSecurityTemplate -Id $Id
        $config = Get-EndpointSecurityConfiguration -Id $Id

        if ($template.templateId -notin $excludedTemplates) {
            $output = [PSCustomObject]@{
                "templateId"    = $template.templateId
                "displayName"   = $template.displayName
                "description"   = $template.description
                "settingsDelta" = @($config.value)
            }

            return $output | ConvertTo-Json -Depth 5
        }
        else {
            Write-Warning "Configuration $($template.displayName) will not be included in export..."
        }
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

# list configured templates
$templates = Get-EndpointSecurityTemplate | Select-Object -ExpandProperty value

# export to file system
$exportPath = Join-Path $PSScriptRoot "EndpointSecurityExport"

Write-Output "Export folder is `"$exportPath`""

if (-not (Test-Path $exportPath)) {
    New-Item -ItemType Directory -Path $exportPath
}

foreach ($template in $templates) {
    Write-Output "Exporting configuration: `"$($template.displayName)`"..."
    $json = Export-EndpointSecurityConfiguration -Id $template.id
    #build file path with partial id to ensure uniqueness
    $filePath = Join-Path $exportPath "$($template.displayName)_$($template.id.Substring(0,3)).json"
    Set-Content -Path $filePath -Value $json -Force
}

Write-Output "Done"
