[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $ReferenceList,
    [Parameter(Mandatory)]
    [string]
    $DifferenceList
)

$policyCSPHive= "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\default\"
$policyCSPListOld = Import-Csv -Path $DifferenceList
$policyCSPListNew = Import-Csv -Path $ReferenceList

#compare lists
$policyCSPComparison = Compare-Object -ReferenceObject $policyCSPListNew -DifferenceObject $policyCSPListOld -Property PSChildname -PassThru

#get new entries
$newPolicyCSPDifference = $policyCSPComparison| Where-Object {$_.SideIndicator -eq "<="}

#get removed entries
$removedPolicyCSPDifference = $policyCSPComparison | Where-Object {$_.SideIndicator -eq "=>"}

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

$policyCSPDifferenceList | Export-Csv -Path "$PSScriptRoot\CSPPolicyList_Diff.csv" -NoTypeInformation


