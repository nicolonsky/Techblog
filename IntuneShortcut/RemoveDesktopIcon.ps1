[CmdletBinding()]
Param (
   [Parameter(Mandatory=$true)]
   [String]$ShortcutDisplayName
)

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

# Remove icon from desktop
Remove-Item -Path $(Join-Path $(Get-DesktopDir) "$ShortcutDisplayName.lnk") -EA SilentlyContinue; 

# Remove icon from start
Remove-Item -Path $(Join-Path $(Get-StartDir) $"$ShortcutDisplayName.lnk") -EA SilentlyContinue