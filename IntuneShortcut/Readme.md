# Create Desktop shortcuts with Microsoft Intune

![Demo](https://tech.nicolonsky.ch/content/images/2019/07/Intune-Create-Desktop-Shortcut.gif)

[Find a full post and desciption on my blog](https://tech.nicolonsky.ch/intune-create-desktop-shortcut/)

Create and remediate desktop and start menu shortcuts with Microsoft Intune using Win32 app deployment. Because with OneDrive Known Folder Move the Desktop is not stored in the default user profile location we need to resolve it with the ```[Environment]::GetFolderPath("Desktop")``` method.

Usage: ```CreateDesktopIcon.exe -ShortcutTargetPath "%ProgramFiles(x86)%\Microsoft\Edge Dev\Application\msedge.exe" -ShortcutDisplayName "nicolonsky tech" -IconFile "https://tech.nicolonsky.ch/favicon.ico" -ShortcutArguments "https://tech.nicolonsky.ch"```

## Quick Overview

* This solution works with OneDrive Known Folder Move
* Everything is user based (local userprofile)
* If a shortcut is missing or deleted it gets automatically (re)created
* Possibility to remove shortcut via Intune Win32 app uninstall
* Shortcut can point to URL, File (UNC) or Folder (UNC)
* Ability to pass shortcut arguments
* Ability to specify shortcut icon (UNC/URL)
* Ability to deploy shortcut with Intune Win32 app dependencies
