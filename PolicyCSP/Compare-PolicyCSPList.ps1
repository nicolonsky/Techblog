$policyCSPHive= "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\default\"
$csvDelimiter=","

$policyCSPList1= Import-Csv -Path "$PSScriptRoot\CSPPolicyList_W10-16299.csv" -Delimiter $csvDelimiter
$policyCSPList2= Import-Csv -Path "$PSScriptRoot\CSPPolicyList_W10-17133.csv" -Delimiter $csvDelimiter

#compare lists

$policyCSPDifference=Compare-Object -ReferenceObject $policyCSPList2 -DifferenceObject $policyCSPList1 -PassThru

#create empty array
$policyCSPDifferenceList=@()

$policyCSPDifference | ForEach-Object {

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

$policyCSPDifferenceList | Export-Csv -Path "$PSScriptRoot\CSPPolicyList_New.csv" -Delimiter $csvDelimiter


