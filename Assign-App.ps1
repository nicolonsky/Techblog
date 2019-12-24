function New-MobileAppAssignment{

    [CmdletBinding(SupportsShouldProcess=$True)]

    param(
        # Parameter help description
        [Parameter(Mandatory)]
        [String]$MobileAppId,
        # Parameter help description
        [Parameter]
        [ValidateSet("available","required","uninstall")]
        [String]$Intent="available"
        )
    
        process{

            $mobileAppAssignment = [PSCustomObject] @{
                id = $(New-Guid),
                intent = $Intent,
            }
        }

        return $( $mobileAppAssignment | Convertto-Json)
}