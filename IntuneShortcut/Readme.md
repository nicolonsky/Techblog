# Create Desktop shortcuts with Microsoft Intune

Create and remediate desktop and start menu shortcuts with Microsoft Intune using Win32 app deployment. Because with OneDrive Known Folder Move the Desktop is not stored in the default user profile location we need to resolve it with the ```[Environment]::GetFolderPath("Desktop")``` method.

Usage: ```CreateDesktopIcon.exe -ShortcutTargetPath "\\app01.intra.contoso.com\Programme\abacus.abalink" -ShortcutDisplayName "Abacus"```

The "Add-Shortcut.ps1" script is wrapped in an exe with Roger Zanders [PS2EXE](http://ps2exe.azurewebsites.net/). Which is again wrapped as Intune Win32 app with the [Win32 Content Prep Tool](https://github.com/Microsoft/Microsoft-Win32-Content-Prep-Tool).

## Quick Overview

* This solution works with OneDrive Known Folder Move
* Everything is user based (local userprofile)
* If a shortcut is missing or deleted it gets automatically (re)created
* Possibility to remove shortcut via Intune Win32 app uninstall
* Shortcut can point to URL, File (UNC) or Folder (UNC)
* Ability to pass shortcut arguments
* Ability to specify shortcut icon (UNC/URL)
* Ability to deploy shortcut with Intune Win32 app dependencies
