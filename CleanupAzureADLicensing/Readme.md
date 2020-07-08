Script to cleanup direct Azure AD license assignments.

Prerequisites:

* Before running the script make sure that you have the `MSOnline` PowerShell module installed.
* Connect to MSOnline with: `Connect-MsolService`

Parameters: 
* Predict changes: `& "Invoke-CleanupAADDirectLicenseAssignments.ps1" -WhatIf`
* Predict changes and save report as csv to script directory: 
`& "Invoke-CleanupAADDirectLicenseAssignments.ps1" -WhatIf -SaveReport `
* Remove direct license assignments: `& "Invoke-CleanupAADDirectLicenseAssignments.ps1"`