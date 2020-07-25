# Replace with the name of your shortcut (without *.lnk)
$shortcutName="cmd"

if ($(whoami -user) -match "S-1-5-18"){
    $runningAsSystem= $true
}

if ($runningAsSystem){

    $desktopDir = Join-Path -Path $env:PUBLIC -ChildPath "Desktop"

}else{

    $desktopDir=$([Environment]::GetFolderPath("Desktop"))
}

if (Test-Path -Path $(Join-Path $desktopDir "$shortcutName.lnk")){

    Write-Output "0"
}
