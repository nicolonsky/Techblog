$azDriveMAppingScriptUrl= "https://ntintune.blob.core.windows.net/intune-scripts/DriveMappingScript.ps1"

$regKeyLocation="HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"

$psCommand= "PowerShell.exe -ExecutionPolicy Bypass -windowstyle hidden -command $([char]34)& {(Invoke-RestMethod '$azDriveMAppingScriptUrl').Replace('ï','').Replace('»','').Replace('¿','') | Invoke-Expression}$([char]34)"

if (-not(Test-Path -Path $regKeyLocation)){

    New-ItemProperty -Path $regKeyLocation -Force
}

Set-ItemProperty -Path $regKeyLocation -Name "PowerShellDriveMapping" -Value $psCommand -Force

Invoke-Expression $psCommand