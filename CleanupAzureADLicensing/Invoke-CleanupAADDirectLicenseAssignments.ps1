#Requires -Module MSOnline
[CmdletBinding(SupportsShouldProcess)]
param (
    # Saves the report to the script location
    [Parameter()]
    [switch]
    $SaveReport
)

# Fetch all users
$allUsers = Get-MsolUser -All -ErrorAction Stop

# little report
$directLicenseAssignmentReport = @()
$directLicenseAssignmentCount = 0

foreach ($user in $allUsers){
    # processing all licenses per user
    foreach ($license in $user.Licenses){
        <#
            the "GroupsAssigningLicense" array contains objectId's of groups which inherit licenses
            if the array contains an entry with the users own objectId the license was assigned directly to the user
            if the array contains no entries and the user has a license assigned he also got a direct license assignment
        #>
        if ($license.GroupsAssigningLicense -contains $user.ObjectId -or $license.GroupsAssigningLicense.Count -lt 1){
           
            $directLicenseAssignmentCount++
            Write-Verbose "User $($user.UserPrincipalName) ($($user.ObjectId)) has direct license assignment for sku '$($license.AccountSkuId)')"
            
            # add details to the report
            $directLicenseAssignmentReport += [PSCustomObject]@{
                UserPrincipalName = $user.UserPrincipalName
                ObjectId = $user.ObjectId
                AccountSkuId = $license.AccountSkuId
                DirectAssignment = $true
            }

            if($PSCmdlet.ShouldProcess($user.UserPrincipalName,"Remove license assignment for sku '$($license.AccountSkuId)'")){
                Write-Warning "Removing license assignment for sku '$($license.AccountSkuId) on target '$($user.UserPrincipalName)'"
                Set-MsolUserLicense -ObjectId $user.ObjectId -RemoveLicenses $license.AccountSkuId
            }
        }
    }
}

if ($directLicenseAssignmentCount -gt 0){
    Write-Output "`nFound $directLicenseAssignmentCount direct assigned license(s):"
    Write-Output $directLicenseAssignmentReport

    if ($SaveReport.IsPresent){
        $exportPath = Join-Path $PSScriptRoot "AADDirectLicenseAssignments.csv"
        $directLicenseAssignmentReport | Export-Csv -Path $exportPath -Encoding "utf8" -NoTypeInformation -WhatIf:$false
        Write-Output "`nSaved report to: '$exportPath'"
    }

}else {
    Write-Output "No direct license assignments found"
}