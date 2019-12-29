 #Requires -Module Microsoft.Graph.Intune

<#PSScriptInfo
    .GUID 6581f5b0-fbb8-45ff-8cb8-8d0a9f0f051f

    .AUTHOR nicola@nicolasuter.ch, https://tech.nicolonsky.ch

    .EXTERNALMODULEDEPENDENCIES  Microsoft.Graph.Intune

    .DESCRIPTION 
    This script monitors apple token expiration in MEMCM (Intune) and checks if DEP, VPP, and APNS tokens, certificates are valided after the number of specified days.
#> 
Param()

###############################################################################################

# treshold days before expiration notification is fired
$notificationTresholdDays = 21

# Microsoft Teams Webhook URI
$webHookUri = "https://outlook.office.com/webhook/7d5dcaef-5326-43a3-b83d-b601e19a5bd6@7955e1b3-cbad-49eb-9a84-e14aed7f3400/IncomingWebhook/0795975319dd4509b9c9f74a0f1de68f/36c9b091-fe88-4dc2-a9e1-2662020b4bab"

# Connect to Microsoft Graph (option #1 via service principal)
$servicePrincipalConnection = Get-AutomationConnection -Name "AzureRunAsConnection" -ErrorAction Stop
Update-MSGraphEnvironment -AuthUrl "https://login.microsoftonline.com/$($servicePrincipalConnection.TenantId)" -AppId $servicePrincipalConnection.ApplicationId
Connect-MSGraph -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint -Quiet

# Connect to Microsoft Graph (option #2 via application & client secret)
<#
    $tenant = "fca7d52d-7253-4784-8c7f-f2dd53e858ec"
    $authority = “https://login.windows.net/$tenant”
    $clientId = “e92ff304-d681-4ba5-bb42-9683e4bd0d25”
    $clientSecret = “<paste your secret here>”
    Update-MSGraphEnvironment -AppId $clientId -Quiet
    Update-MSGraphEnvironment -AuthUrl $authority -Quiet
    Connect-MSGraph -ClientSecret $ClientSecret -Quiet
#>

# Connect to Microsoft Graph (option #3 via credentials)
<#
    $creds = Get-AutomationPSCredential -Name "appletokenservice@nicolonsky.ch"
    Connect-MSGraph -Credential $creds -Quiet
#>

###############################################################################################

# Get initial domain name to display as tenant name on teams card
$organization =  Invoke-MSGraphRequest -HttpMethod GET -Url "organization"
$orgDomain = $organization.value.verifiedDomains | Where-Object {$_.isInitial} | Select-Object -ExpandProperty name

# optional mail configuration
<# 
    $mailConfig = @{
        SMTPServer = "smtp.office365.com"
        SMTPPort = "587"
        Sender = "appletokenservice@nicolonsky.ch"
        Recipients = @("nicola@nicolonsky.ch", "helpdesk@nicolonsky.ch")
        Header = "Apple token expiration in MEMCM for tenant: $orgDomain"
    }
#>

# JSON template for teams card message
$bodyTemplate = @"
    {
        "@type": "MessageCard",
        "@context": "https://schema.org/extensions",
        "summary": "Apple token expiration in MEMCM",
        "themeColor": "D778D7",
        "title": "Apple token expiration in MEMCM",
         "sections": [
            {
                "facts": [
                    {
                        "name": "Token Type:",
                        "value": "TOKEN_TYPE"
                    },
                    {
                        "name": "Token Name:",
                        "value": "TOKEN_NAME"
                    },
                    {
                        "name": "Expiration datetime:",
                        "value": "TOKEN_EXPIRATION_DATETIME"
                    },
                    {
                        "name": "Help URL:",
                        "value": "[Microsoft Docs: Renew iOS certificate and tokens](https://docs.microsoft.com/en-us/intune-education/renew-ios-certificate-token)"
                    }
                ],
                "text": "The following Apple token in your Intune Tenant: _$($orgDomain)_ is about to expire:"
            }
        ]
    }
"@

# Mail message template
$mailTemplate = @"
  <html>
  <body>
    <h1>Attention: Apple token expiration in MEMCM!</h1>
    <br>
    Please make sure to renew your expired apple token in MEMCM!
    <br>
    <br>
    <b>Token type:</b> TOKEN_TYPE 
    <br>
    <b>Token Name:</b> TOKEN_NAME 
    <br>
    <b>Expiration Datetime:</b> TOKEN_EXPIRATION_DATETIME <br>
    <b>Help URL: <a href="https://docs.microsoft.com/en-us/intune-education/renew-ios-certificate-token">Microsoft Docs</a><br>
    <br>
    <br/>
  </body>
</html>
"@

# Add configured days to current date for treshold comparison
$notificationTreshold = (Get-Date).AddDays($notificationTresholdDays)

# Process Apple push notification certificate and check for expiration
$applePushNotificationCertificate = Get-DeviceManagement_ApplePushNotificationCertificate

if ($notificationTreshold -ge $applePushNotificationCertificate.expirationDateTime){

    Write-Verbose "Token $($applePushNotificationCertificate.'@odata.context'): $($applePushNotificationCertificate.appleIdentifier) will expire soon!"

    # if mailconfig is enabled use mail template instead of teams card
    if ($mailConfig){

        $bodyTemplate = $mailTemplate
    }

    $bodyTemplate = $bodyTemplate.Replace("TOKEN_TYPE", "Apple Push Notification Certificate")
    $bodyTemplate = $bodyTemplate.Replace("TOKEN_NAME", $applePushNotificationCertificate.appleIdentifier)
    $bodyTemplate = $bodyTemplate.Replace("TOKEN_EXPIRATION_DATETIME", $applePushNotificationCertificate.expirationDateTime)

    if (-not $mailConfig){

        $request = Invoke-WebRequest -Method Post -Uri $webHookUri -Body $bodyTemplate -UseBasicParsing

    }else{

        $creds = Get-AutomationPSCredential -Name $mailConfig.sender
        Send-MailMessage -UseSsl -From $mailConfig.Sender -To $mailConfig.Recipients -SmtpServer $mailConfig.SMTPServer -Port $mailConfig.SMTPPort -Subject $mailConfig.Header -Body $bodyTemplate -Credential $creds -BodyAsHtml
    }
}else{

    Write-Verbose "Token $($applePushNotificationCertificate.'@odata.context'): $($applePushNotificationCertificate.appleIdentifier) still valid!"
}

# Process all Apple vpp tokens and check if they will expire soon
$appleVppTokens = Get-DeviceAppManagement_VppTokens

$appleVppTokens | ForEach-Object {

    $appleVppToken = $PSItem

    if ($notificationTreshold -ge $appleVppToken.tokenExpirationDateTime){

        Write-Verbose "Token $($appleVppToken.'@odata.context'): $($appleVppToken.appleIdentifier) will expire soon!"

        # if mailconfig is enabled use mail template instead of teams card
        if ($mailConfig){

            $bodyTemplate = $mailTemplate
        }

        $bodyTemplate = $bodyTemplate.Replace("TOKEN_TYPE", "Apple VPP Token")
        $bodyTemplate = $bodyTemplate.Replace("TOKEN_NAME", "$($appleVppToken.organizationName): $($appleVppToken.appleId)")
        $bodyTemplate = $bodyTemplate.Replace("TOKEN_EXPIRATION_DATETIME", $appleVppToken.expirationDateTime)

        if (-not $mailConfig){

            $request = Invoke-WebRequest -Method Post -Uri $webHookUri -Body $bodyTemplate -UseBasicParsing
    
        }else{
    
            $creds = Get-AutomationPSCredential -Name $mailConfig.sender
            Send-MailMessage -UseSsl -From $mailConfig.Sender -To $mailConfig.Recipients -SmtpServer $mailConfig.SMTPServer -Port $mailConfig.SMTPPort -Subject $mailConfig.Header -Body $mailTemplate -Credential $creds 
        }
    }else{

        Write-Verbose "Token $($appleVppToken.'@odata.context'): $($appleVppToken.appleIdentifier) still valid!"
    }
}

# Process all Apple DEP Tokens (we have to switch to the beta endpoint)
Update-MSGraphEnvironment -SchemaVersion "Beta" -Quiet
Connect-MSGraph -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint -Quiet

$appleDepTokens = (Invoke-MSGraphRequest -HttpMethod GET -Url "deviceManagement/depOnboardingSettings").value

$appleDepTokens | ForEach-Object {

    $appleDepToken = $PSItem

    if ($notificationTreshold -ge $appleDepToken.tokenExpirationDateTime){

        Write-Verbose "Token $($appleDepToken.'@odata.context'): $($appleDepToken.appleIdentifier) will expire soon!"

        # if mailconfig is enabled use mail template instead of teams card
        if ($mailConfig){

            $bodyTemplate = $mailTemplate
        }

        $bodyTemplate = $bodyTemplate.Replace("TOKEN_TYPE", "Apple VPP Token")
        $bodyTemplate = $bodyTemplate.Replace("TOKEN_NAME", "$($appleDepToken.tokenName): $($appleDepToken.appleIdentifier)")
        $bodyTemplate = $bodyTemplate.Replace("TOKEN_EXPIRATION_DATETIME", $appleDepToken.tokenExpirationDateTime)

        if (-not $mailConfig){

            $request = Invoke-WebRequest -Method Post -Uri $webHookUri -Body $bodyTemplate -UseBasicParsing
    
        }else{
    
            $creds = Get-AutomationPSCredential -Name $mailConfig.sender
            Send-MailMessage -UseSsl -From $mailConfig.Sender -To $mailConfig.Recipients -SmtpServer $mailConfig.SMTPServer -Port $mailConfig.SMTPPort -Subject $mailConfig.Header -Body $mailTemplate -Credential $creds 
        }

    }else{

        Write-Verbose "Token $($appleDepToken.'@odata.context'): $($appleDepToken.appleIdentifier) still valid!"
    }
}