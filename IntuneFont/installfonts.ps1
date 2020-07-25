$fontFolderName = "fonts"

$supportedFonts = @{
    ".otf" = "OpenType"
    ".ttf" = "TrueType"
}

$potentialFonts = Get-ChildItem -Path $(Join-Path $PSScriptRoot $fontFolderName)

foreach ($font in $potentialFonts){
    
    try{

        $fontType = $font.Extension

        if ($supportedFonts.Keys -contains $fontType){
            
            Write-Output "$($font.Name) is $($supportedFonts[$fontType]) font"
            
            # Copy and reference font
            $null = Copy-Item -Path $font.FullName -Destination "C:\Windows\Fonts\" -Force -EA Stop
            $null = New-ItemProperty -Name "$($font.BaseName) ($($supportedFonts[$fontType]))" -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -PropertyType string -Value $font.Name -Force -EA Stop

            Write-Output "Installed font $($font.Name)"
        }else {
            Write-Warning "Unrecognized font type '$($fontType)' $($font.Name)"
        }

    }catch{
        Write-Error $_
    }
}