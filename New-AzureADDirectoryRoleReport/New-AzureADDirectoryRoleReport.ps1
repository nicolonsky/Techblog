#Requires -Module AzureAD

<#
    .DESCRIPTION
    This script exports all assigned Azure Active Directory roles to a *.csv file.

#>

function Get-BetterAzureADDirectoryRoleAssignments {
    [CmdletBinding()]
    param ()

    process {

        $roleAssignments = @()
        # Process all enabled Azure AD Roles
        Get-AzureADDirectoryRole | ForEach-Object {

            $currentRoleName = $PSItem.DisplayName
            Write-Verbose "Processing role: $currentRoleName"
            # Get all members of current role
            $roleMembers = Get-AzureADDirectoryRoleMember -ObjectId $($PSItem.ObjectId)
            # Add members to hashtable
            $roleMembers | ForEach-Object {

                # Distinguish between users and service principals
                if ($_.ObjectType -match "ServicePrincipal"){

                    $memberName = "$($PSItem.AppDisplayName) ($($PSItem.AppId))"

                }elseif ($_.ObjectType -match "Group") {
                        $memberName = "$($PSItem.DisplayName)"
                }else {
                    $memberName = $PSItem.UserPrincipalName
                }

                $roleAssignments += [PSCustomObject]@{
                    Role = $currentRoleName
                    Member = $memberName
                    ObjectType = $_.ObjectType
                }
            }
        }

        return $roleAssignments
    }
}

# Check Azure AD Access token
if ($null -eq [Microsoft.Open.Azure.AD.CommonLibrary.AzureSession]::AccessTokens){
    Connect-AzureAD
} else {
    $token = [Microsoft.Open.Azure.AD.CommonLibrary.AzureSession]::AccessTokens
    Write-Verbose "Connected to tenant: $($token.AccessToken.TenantId) with user: $($token.AccessToken.UserId)"
}

#Get all role assignments
$roleAssignments = Get-BetterAzureADDirectoryRoleAssignments

$exportPath = Join-Path $PSScriptRoot "AzureADDirectoryRoleAssignments_$(get-date -f yyyy-MM-dd).csv"

# Export as CSV to current directory
$roleAssignments | Export-Csv -Path $exportPath -NoTypeInformation -Delimiter ";"

Write-Output "`nExported role assignments to: '$exportPath'"
Write-Output $roleAssignments

<# Snippet to compare two different exports
$firstReport = Import-Csv -Path "AzureADDirectoryRoleAssignments_2020-03-13 - Copy.csv" -Delimiter ";"
$secondReport = Import-Csv -Path "AzureADDirectoryRoleAssignments_2020-03-13.csv" -Delimiter ";"
Compare-Object $firstReport $secondReport
#>

<# snippet to count assignments per role
$roleAssignments | Group-Object -Property Role | Sort-Object -Descending | Select-Object -Property Name,Count
#>
