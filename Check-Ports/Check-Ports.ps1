#Requieres -Version 5.0

<#

.SYNOPSIS 
    You can use this script for troubleshooting or engineering purposes to verify if TCP ports are opened.    

.DESCRIPTION
	With this Script you are able to specify server names and port numbers to check in a CSV File. 
    The Script generates an CSV output file as a report.
    The script will generate an output file for the same path containing the suffix "Report_" with the test results.

.PARAMETER Path
    Path to the CSV template containing the server name and port

.NOTES
	Author: Nicola / http://tech.nicolonsky.ch
	Date:   18.10.2017

.EXAMPLE
    &"Check-Ports.ps1" -Path "CheckList.csv"

History
    001: First Version
#>

[CmdletBinding()]
Param(
  
  [Parameter(Mandatory=$True,Position=1)]

    [ValidateScript({
        
        Test-Path $_ -PathType Leaf

    })]

   [string]
   $Path
)


$checkList=Import-Csv -Path $Path -Delimiter ";" -ErrorAction Stop

$checkList| ForEach-Object {

    try{
        
        if (Test-NetConnection -ComputerName $_.Server -Port $_.Port -InformationLevel Quiet -ErrorAction Stop){
            
            $_.Open=$true
        
        }else{
            
            $_.Open=$false
        
        }
    
    }catch{
        #Nothing we can do because the -ErrorAction is ignored 
    }
}


$outputObject=Get-Item $Path

#Build file name for the report
$exportPath= Join-Path -Path $outputObject.DirectoryName -ChildPath $("Report_"+ $outputObject.BaseName + $outputObject.Extension)

$checkList | Export-Csv -Path $exportPath -NoTypeInformation -Delimiter ";" -ErrorAction Stop