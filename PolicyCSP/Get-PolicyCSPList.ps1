$PolicyCSPHive= "HKLM:\SOFTWARE\Microsoft\PolicyManager\default"

$PolicyCSPHivePSPath= Get-Item $PolicyCSPHive | Select -ExpandProperty PSPath

$policyCSPEntries=Get-ChildItem -Path $PolicyCSPHive -Recurse | Where {$_.PSParentPath -ne $PolicyCSPHivePSPath} | Select Name, PSChildName
     
$windosBuild= Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name CurrentBuild

$policyCSPEntries| Export-Csv -Path $(Join-Path -Path $PSScriptRoot -ChildPath "CSPPolicyList_W10-$($windosBuild.CurrentBuild).csv") -Delimiter "," -NoTypeInformation -Force



