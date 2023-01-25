# 1.7 Installing the Cascadia Code Font
#
# Run on SRV1 after you install PowerShell 7 and VS Code
# RUn in VS code

# 1. Getting download locations
$CascadiaFont    = 'CascadiaCode'    # font file name
$CascadiaRelURL  = 
        'https://github.com/microsoft/cascadia-code/releases'
$CascadiaRelease = Invoke-WebRequest -Uri $CascadiaRelURL
$Fileleaf        = ($CascadiaRelease.Links.href |
                     Where-Object { $_ -match $CascadiaFont } |
                       Select-Object -First 1)
$CascadiaPath   = 'https://github.com' + $FileLeaf
$CascadiaFile   = 'C:\Foo\CascadiaFontDL.zip'

# 2. Downloading the Cascadia Code font file archive
Invoke-WebRequest -Uri $CascadiaPath -OutFile $CascadiaFile

# 3. Expanding the font archive file
$CascadiaFontFolder = 'C:\Foo\CascadiaCode'
Expand-Archive -Path $CascadiaFile -DestinationPath $CascadiaFontFolder

# 4. Installing the Cascadia Code font
$FontFile = 'C:\Foo\CascadiaCode\ttf\CascadiaCode.ttf'
$FontShellApp = New-Object -Com Shell.Application
$FontShellNamespace = $FontShellApp.Namespace(0x14)
$FontShellNamespace.CopyHere($FontFile, 0x10)