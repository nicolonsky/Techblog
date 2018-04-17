$policyCSPHive= "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\default\"
$csvDelimiter=","

$policyCSPListOld= Import-Csv -Path "$PSScriptRoot\CSPPolicyList_W10-16299.csv" -Delimiter $csvDelimiter
$policyCSPListNew= Import-Csv -Path "$PSScriptRoot\CSPPolicyList_W10-17133.csv" -Delimiter $csvDelimiter

#compare lists
$policyCSPComparison=Compare-Object -ReferenceObject $policyCSPListNew -DifferenceObject $policyCSPListOld -Property PSChildname -PassThru

#get new entries
$newPolicyCSPDifference= $policyCSPComparison| Where-Object {$_.SideIndicator -eq "<="}

#get removed entries
$removedPolicyCSPDifference= $policyCSPComparison | Where-Object {$_.SideIndicator -eq "=>"}

#create empty array
$policyCSPDifferenceList=@()

$newPolicyCSPDifference | ForEach-Object {

    #remove entire registry path
    $formattedPath=$($PSItem.Name).Replace($policyCSPHive,"")

    #build category name
    $category=$formattedPath.Replace($("\"+$PSItem.PSChildName),"")

    #create temporary object
    $tempObject = New-Object -TypeName PSObject
    $tempObject | Add-Member -Type NoteProperty -Name Group -Value $category
    $tempObject | Add-Member -Type NoteProperty -Name Setting -Value $PSItem.PSChildname

    #add to array
    $policyCSPDifferenceList+= $tempObject    
}

$policyCSPDifferenceList | Export-Csv -Path "$PSScriptRoot\CSPPolicyList_New.csv" -Delimiter $csvDelimiter -NoTypeInformation


