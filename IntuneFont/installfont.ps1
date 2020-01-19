[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 1)]
    [String]
    $FontFileName
)

Start-Transcript -Path $(Join-Path $env:TEMP "InstallFont.log")

try{
    Write-Output "Font file '$FontFileName' passed as argument"
    Write-Output "Copying item to: '$("$env:windir\Fonts\$FontFileName")'"
    Copy-Item -Path "$PSScriptRoot\$FontFileName" -Destination "$env:windir\Fonts" -Force -PassThru -ErrorAction Stop
    Write-Output "Creating item: 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts\$FontFileName'"
    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" -Name $FontFileName -PropertyType String -Value $FontFileName -Force
}catch{
    Write-Error $_
}

Stop-Transcript