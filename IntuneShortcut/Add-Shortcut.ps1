[CmdletBinding()]
Param (
   [Parameter(Mandatory=$true)]
   [String]$ShortcutTargetPath,

   [Parameter(Mandatory=$true)]
   [String]$ShortcutDisplayName,

   [Parameter(Mandatory=$false)]
   [Switch]$PinToStart=$false,

   [Parameter(Mandatory=$false)]
   [String]$IconFile="https://www.microsoft.com/favicon.ico"
)

$desktopDir=$([Environment]::GetFolderPath("Desktop"))
$startMenuDir=[Environment]::GetFolderPath("StartMenu")

$destinationPath= Join-Path -Path $desktopDir -ChildPath "$shortcutDisplayName.lnk"

$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($destinationPath)
$Shortcut.TargetPath = $ShortcutTargetPath
$Shortcut.IconLocation = $IconFile
$Shortcut.Save()


if ($PinToStart.IsPresent -eq $true){

    $destinationPath = Join-Path -Path $startMenuDir -ChildPath $fullShortcutName
    $Shortcut = $WshShell.CreateShortcut($destinationPath)
    $Shortcut.TargetPath = $ShortcutTargetPath
    $Shortcut.IconLocation = $IconFile
    $Shortcut.Save()
}

[Runtime.InteropServices.Marshal]::ReleaseComObject($WshShell) | Out-Null