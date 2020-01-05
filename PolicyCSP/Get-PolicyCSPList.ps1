$PolicyCSPHive= "HKLM:\SOFTWARE\Microsoft\PolicyManager\default"
$PolicyCSPHivePSPath = Get-Item $PolicyCSPHive | Select-Object -ExpandProperty PSPath
$policyCSPEntries = Get-ChildItem -Path $PolicyCSPHive -Recurse | Where-Object {$_.PSParentPath -ne $PolicyCSPHivePSPath -and $_.Name -notmatch "knobs"} | Select-Object Name, PSChildName
$windwosBuild = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name CurrentBuild
# Export CSP's as csv
$policyCSPEntries| Export-Csv -Path $(Join-Path -Path $PSScriptRoot -ChildPath "CSPPolicyList_W10-$($windwosBuild.CurrentBuild).csv") -NoTypeInformation -Force



