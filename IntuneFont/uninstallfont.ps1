[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 1)]
    [String]
    $FontFileName
)

Start-Transcript -Path $(Join-Path $env:TEMP "UninstallFont.log")

try{
    Write-Output "Font file '$FontFileName' passed as argument"
    Write-Output "Deleting item: '$("$env:windir\Fonts\$FontFileName")'"
    Remove-Item -Path "$env:windir\Fonts\$FontFileName" -Force
    Write-Output "Deleting item: 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts\$FontFileName'"
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" -Name $FontFileName -Force
}catch{
    Write-Error $_
}

Stop-Transcript