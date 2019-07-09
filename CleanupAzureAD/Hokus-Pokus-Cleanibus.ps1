#Requires -Modules AzureAD

#enter treshold days 
$deletionTresholdDays= 90

Connect-AzureAD -ErrorAction Stop

$deletionTreshold= (Get-Date).AddDays(-$deletionTresholdDays)

$allDevices=Get-AzureADDevice -All:$true | Where-Object {$_.ApproximateLastLogonTimeStamp -le $deletionTreshold}

$exportPath=$(Join-Path $PSScriptRoot "AzureADDeviceExport.csv")

$allDevices | Select-Object -Property DisplayName, ObjectId, ApproximateLastLogonTimeStamp, DeviceOSType, DeviceOSVersion, IsCompliant, IsManaged `
| Export-Csv -Path $exportPath -UseCulture -NoTypeInformation

Write-Output "Find report with all devices under: $exportPath"

$confirmDeletion=$null

while ($confirmDeletion -notmatch "[y|n]"){

    $confirmDeletion = Read-Host "Delete all Azure AD devices which haven't contacted your tenant since $deletionTresholdDays days (Y/N)"
}

if ($confirmDeletion -eq "y"){

    $allDevices | ForEach-Object {

        Write-Output "Removing device $($PSItem.ObjectId)"

        Remove-AzureADDevice -ObjectId $PSItem.ObjectId
    }

} else {
   
    Write-Output "Exiting..."
}