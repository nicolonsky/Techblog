#Requires -Module MSAL.PS

[CmdletBinding()]
param (
    # Configuration Profile ID of the Intune policy containing the applocker policy
    [Parameter(Mandatory = $true)]
    [guid]
    $ProfileId
)

# Connect to Microsoft Intune PowerShell App
$params = @{
    ClientId   = "d1ddf0e4-d672-4dae-b554-9d5bdfd93547"
    DeviceCode = $true
}

#base url for requests
$script:graphUrl = "https://graph.microsoft.com/v1.0/deviceManagement"

# verify token
if (-not ($token -and $token.ExpiresOn.LocalDateTime -ge $(Get-Date))) {
    $token = Get-MsalToken @params
}

#auth header used to pass the access token
$script:authHeader = @{
    'Authorization' = $token.CreateAuthorizationHeader()
}

# combine request url
$requestUrl = $script:graphUrl + "/" + "deviceConfigurations" + "/" + $ProfileId

# fetch applocker profile
$configurationProfile = Invoke-RestMethod -Method Get -Uri $requestUrl -Headers $script:authHeader

foreach ($setting in $configurationProfile.omaSettings) {
    Write-Output "Processing entry: `"$($setting.displayName)`" ($($setting.omaUri))"
    try {
        [xml]$base64XmlContent = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($setting.value))

        #
        [System.Xml.XmlWriterSettings] $xmlSettings = New-Object System.Xml.XmlWriterSettings

        # Preserve Windows formating
        $xmlSettings.Indent = $true

        # Keeping UTF-8 without BOM
        $xmlSettings.Encoding = New-Object System.Text.UTF8Encoding($false)

        # Combine export path
        $exportPath = Join-Path -Path $PSScriptRoot -ChildPath "$($setting.displayName).xml"

        # Write xml to disk
        [System.Xml.XmlWriter] $xmlWriter = [System.Xml.XmlWriter]::Create($exportPath, $xmlSettings)
        $base64XmlContent.Save($xmlWriter)

        # Close Handle and flush
        $xmlWriter.Dispose()

        Write-Output "Exported XML to: `"$exportPath`""
    }
    catch {
        Write-Error $_
    }
}