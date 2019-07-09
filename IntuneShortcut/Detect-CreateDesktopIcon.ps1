$shortcutName="PROFFIX"

$desktopDir=$([Environment]::GetFolderPath("Desktop"))

if (Test-Path -Path $(Join-Path $desktopDir "$shortcutName.lnk")){

    Write-Output "0"
}