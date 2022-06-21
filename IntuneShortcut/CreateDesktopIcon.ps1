[CmdletBinding()]
Param (
   [Parameter(Mandatory=$true)]
   [String]$ShortcutTargetPath,

   [Parameter(Mandatory=$true)]
   [String]$ShortcutDisplayName,

   [Parameter(Mandatory=$false)]
   [Switch]$PinToStart=$false,

   [Parameter(Mandatory=$false)]
   [String]$IconFile=$null,
   
   [Parameter(Mandatory=$false)]
   [Switch]$IconFileIsIncluded=$false,

   [Parameter(Mandatory=$false)]
   [String]$ShortcutArguments=$null,

   [Parameter(Mandatory=$false)]
   [String]$WorkingDirectory=$null
)

#helper function to avoid uneccessary code
function Add-Shortcut {
    param (
        [Parameter(Mandatory)]
        [String]$ShortcutTargetPath,
        [Parameter(Mandatory)]
        [String] $DestinationPath,
		[Parameter(Mandatory)]
        [String]$DestinationName,
        [Parameter()]
        [String] $WorkingDirectory,
		[Parameter()]
        [String] $IconFilePath
    )

    process{
		# due to WScript supporting only ANSI had to pull a rename here
		$tempDestinationPath = Join-Path -Path $DestinationPath -ChildPath "updatingshortcut.lnk"
		$finalDestinationPath = Join-Path -Path $DestinationPath -ChildPath "$DestinationName.lnk"
		
        $WshShell = New-Object -comObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut($tempDestinationPath)
        $Shortcut.TargetPath = $ShortcutTargetPath
        $Shortcut.Arguments = $ShortcutArguments
        $Shortcut.WorkingDirectory = $WorkingDirectory
    
        if ($IconFile){
            $Shortcut.IconLocation = $IconFilePath
        }
        # Create the shortcut
        $Shortcut.Save()
		# rename shortcut - WScript can only handle ANSI. This allows unicode:
		Move-Item -Path $tempDestinationPath -Destination $finalDestinationPath 
        #cleanup
        [Runtime.InteropServices.Marshal]::ReleaseComObject($WshShell) | Out-Null
    }
}

#check if running as system
function Test-RunningAsSystem {
    [CmdletBinding()]
    param()
    process{
        return ($(whoami -user) -match "S-1-5-18")
    }
}

function Get-DesktopDir {
    [CmdletBinding()]
    param()
    process{
        if (Test-RunningAsSystem){
            $desktopDir = Join-Path -Path $env:PUBLIC -ChildPath "Desktop"
        }else{
            $desktopDir=$([Environment]::GetFolderPath("Desktop"))
        }
        return $desktopDir
    }
}

function Get-StartDir {
    [CmdletBinding()]
    param()
    process{
        if (Test-RunningAsSystem){
            $startMenuDir= Join-Path $env:ALLUSERSPROFILE "Microsoft\Windows\Start Menu\Programs"
        }else{
            $startMenuDir="$([Environment]::GetFolderPath("StartMenu"))\Programs"
        }
        return $startMenuDir
    }
}

function Copy-IconToLocalPC {
	param (
        [Parameter(Mandatory)]
        [String]$IconFileName
    )
	process{
		# create a directory to store the icon if it does not exist
		if (-not (Test-Path "C:\ProgramData\AutoPilotConfig\")){
			New-Item -Path "C:\ProgramData\AutoPilotConfig\" -ItemType Directory
		}
		# copy the icon file if it does not exist
		if (-not (Test-Path "C:\ProgramData\AutoPilotConfig\$IconFileName")){
			Copy-Item -Path "$IconFileName" -Destination "C:\ProgramData\AutoPilotConfig"
		}
		return "C:\ProgramData\AutoPilotConfig\$IconFileName"
	}
}

#### Desktop Shortcut
if($IconFileIsIncluded){
	$IconFilePath = Copy-IconToLocalPC -IconFileName $IconFile
} else{
	$IconFilePath = $IconFile
}
Add-Shortcut -DestinationPath $(Get-DesktopDir) -DestinationName $shortcutDisplayName -ShortcutTargetPath $ShortcutTargetPath -WorkingDirectory $WorkingDirectory -IconFilePath $IconFilePath

#### Start menu entry
if ($PinToStart.IsPresent -eq $true){
    $destinationPath = Join-Path -Path $(Get-StartDir) -ChildPath "$shortcutDisplayName.lnk"
    Add-Shortcut -DestinationPath $destinationPath -ShortcutTargetPath $ShortcutTargetPath -WorkingDirectory $WorkingDirectory
}