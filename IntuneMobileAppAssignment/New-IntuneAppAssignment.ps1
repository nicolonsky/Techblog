function New-IntuneMobileAppAssignment {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # ID of the mobile app
        [Parameter(Mandatory)]
        [guid]
        $AppID,

        # Intent of the assignment
        [Parameter()]
        [ValidateSet('available', 'required', 'uninstall', 'availableWithoutEnrollment')]
        [string]
        $Intent = "required",

        # Azure AD Group ID for group assignments
        [Parameter(Mandatory, ParameterSetName = "groupAssignmentTarget")]
        [guid]
        $GroupID,

        # All users assignment
        [Parameter(Mandatory, ParameterSetName = "allLicensedUsersAssignmentTarget")]
        [switch]
        $AllUsersAssignment,

        # All devices assignment
        [Parameter(Mandatory, ParameterSetName = "allDevicesAssignmentTarget")]
        [switch]
        $AllDevicesAssignment

    )

    process {

        Write-Verbose "Creating assignment for app '$AppID'"
        Write-Verbose "Intent: '$Intent'"

        if ($PSCmdlet.ParameterSetName -eq "groupAssignmentTarget") {
            Write-Verbose "Target: AAD Group '$GroupID'"
            # Map to AAD Group ID
            $target = @{
                "@odata.type" = "#microsoft.graph.groupAssignmentTarget"
                "groupId"     = $GroupID
            }
        }

        if ($PSCmdlet.ParameterSetName -eq "allLicensedUsersAssignmentTarget") {
            # Map to all users
            $target = @{
                "@odata.type" = "#microsoft.graph.allLicensedUsersAssignmentTarget"
            }
        }

        if ($PSCmdlet.ParameterSetName -eq "allDevicesAssignmentTarget") {
            # Map to all devices
            $target = @{
                "@odata.type" = "#microsoft.graph.allDevicesAssignmentTarget"
            }
        }

        # Build assignment request body
        if ($PSCmdlet.ShouldProcess($AppID, "Fetching app details")) {
            # Check for app type, e.g. Win32 / MSI APP and build deployment settings
            $appDetails = Get-IntuneMobileApp -AppID $AppID
        }

        # MSI's do not require specific settings
        $settings = $null

        if ($appDetails.'@odata.type' -eq "#microsoft.graph.win32LobApp") {
            $settings = @{
                "@odata.type"                  = "#microsoft.graph.win32LobAppAssignmentSettings"
                "notifications"                = "hideAll"
                "restartSettings"              = $null
                "installTimeSettings"          = $null
                "deliveryOptimizationPriority" = "notConfigured"
            }
        }

        $assignment = @{
            '@odata.type' = "#microsoft.graph.mobileAppAssignment"
            'intent'      = $Intent
            'target'      = $target
            'settings'    = $settings
        }

        $requestBody = $assignment | ConvertTo-Json -Depth 5
        $requestUrl = $script:graphUrl + "/deviceAppmanagement/mobileApps/$AppID/assignments"

        if ($PSCmdlet.ShouldProcess($assignment['target'].'@odata.type', "Creating mobile app assignment")) {
            try {
                $assignmentRequest = Invoke-RestMethod -Method Post -Uri $requestUrl -Body $requestBody -Headers $authHeader -EA Stop -Verbose:$false
                Write-Verbose "Successfully created assignment"
                return $assignmentRequest
            }
            catch {
                $local:errorMessage = $_.ErrorDetails.Message | ConvertFrom-Json
                if ($local:errorMessage.error.message -like "{*") {
                    $nestedMessage = $local:errorMessage.error.message | ConvertFrom-Json
                    Write-Error $nestedMessage.Message
                }
                else {
                    Write-Error $local:errorMessage.error.message
                }
            }
        }
    }
}

function New-SecurityGroup {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # Display Name
        [Parameter(Mandatory)]
        [string]
        $DisplayName,

        # Description Name
        [Parameter()]
        [string]
        $Description
    )

    process {

        # Check if group exists
        if ($PSCmdlet.ShouldProcess("$DisplayName", "Checking if group exists")) {
            $searchUri = $script:graphUrl + "/groups?`$search=`"displayName:$DisplayName`""
            $search = Invoke-RestMethod -Method Get -Uri $searchUri -Headers $authHeader
        }

        # Create the group if not already there
        if ($search.value.Count -eq 0) {
            $group = @{
                displayName     = $DisplayName
                description     = $Description
                mailEnabled     = $false
                securityEnabled = $true
                mailNickname    = $DisplayName
            }

            $requestBody = $group | ConvertTo-Json -Depth 5
            $requestUrl = $script:graphUrl + "/groups"

            if ($PSCmdlet.ShouldProcess($group['displayName'], "Creating AAD Group")) {
                try {
                    $groupRequest = Invoke-RestMethod -Method Post -Uri $requestUrl -Body $requestBody -Headers $authHeader -EA Stop -Verbose:$false
                    return $groupRequest
                }
                catch {
                    $local:errorMessage = $_.ErrorDetails.Message | ConvertFrom-Json
                    if ($local:errorMessage.error.message -like "{*") {
                        $nestedMessage = $local:errorMessage.error.message | ConvertFrom-Json
                        Write-Error $nestedMessage.Message
                    }
                    else {
                        Write-Error $local:errorMessage.error.message
                    }
                }
            }
        }
        # Group is already there
        elseif ($search.value.Count -eq 1) {
            $group = $search.value[0]
            Write-Warning "Group '$($group.displayName)' ($($group.id)) already exists"
            return $group
        }
        # Ambigous groups -> manual cleanup required
        else {
            $group = $search.value[0]
            Write-Error "Multiple groups with name '$($group.displayName)' exist"
        }
    }
}

function Get-IntuneMobileApp {
    [CmdletBinding()]
    param (
        # Aplication ID
        [Parameter(Mandatory, ParameterSetName = "Single")]
        [guid]
        $AppID,

        # List all apps
        [Parameter(Mandatory, ParameterSetName = "All")]
        [switch]
        $All
    )

    process {
        try {

            $requestUrl = $script:graphUrl + "/deviceAppmanagement/mobileApps"

            if ($All.IsPresent) {

                $requestUrl += "?`$filter=isOf('microsoft.graph.win32LobApp') or isOf('microsoft.graph.windowsMobileMSI')"
                $mobileApps = Invoke-RestMethod -Method Get -Uri $requestUrl -Headers $authHeader -EA Stop
                return $mobileApps.value
            }
            # only fetch specified app
            else {
                $requestUrl += "/$AppID"
                $mobileApp = Invoke-RestMethod -Method Get -Uri $requestUrl -Headers $authHeader
                return $mobileApp
            }
        }
        catch {
            $local:errorMessage = $_.ErrorDetails.Message | ConvertFrom-Json
            if ($local:errorMessage.error.message -like "{*") {
                $nestedMessage = $local:errorMessage.error.message | ConvertFrom-Json
                Write-Error $nestedMessage.Message
            }
            else {
                Write-Error $local:errorMessage.error.message
            }
        }
    }
}

# configuration for groups
$installPattern = "gs-as-msi-app-sd-"
$uninstallPattern = "gs-as-msi-app-sr-"
$groupDescription = "Automatically generated software deployment group"

# Graph API URL (beta)
$script:graphUrl = "https://graph.microsoft.com/beta"

# Get token for graph from MSAL
$accessToken = Get-MsalToken -ClientId d1ddf0e4-d672-4dae-b554-9d5bdfd93547 -RedirectUri "urn:ietf:wg:oauth:2.0:oob" -Interactive

# Build authentication header for API requests
$authHeader = @{
    'Content-Type'     = 'application/json'
    'Authorization'    = $accessToken.CreateAuthorizationHeader()
    'ExpiresOn'        = $accessToken.ExpiresOn.LocalDateTime
    'ConsistencyLevel' = "eventual"
}

# select via gridView
$mobileApps = Get-IntuneMobileApp -All | Select-Object '@odata.type', displayName, id | Out-GridView -PassThru -Title "Select mobileApps"

foreach ($mobileApp in $mobileApps) {
    # construct group names
    $appName = $mobileApp.displayName.Replace(' ', '_')
    $installGroupName = $installPattern + $appName
    $uninstallGroupName = $uninstallPattern + $appName

    # create install group
    $installGroup = New-SecurityGroup -DisplayName $installGroupName -Description $groupDescription

    # assign to install group
    New-IntuneMobileAppAssignment -AppID $mobileApp.id -Intent required -GroupID $installGroup.id -Verbose

    # create uninstall group
    $uninstallGroup = New-SecurityGroup -DisplayName $uninstallGroupName -Description $groupDescription

    # assign to uninstall group
    New-IntuneMobileAppAssignment -AppID $mobileApp.id -Intent uninstall -GroupID $uninstallGroup.id -Verbose
}

# finito