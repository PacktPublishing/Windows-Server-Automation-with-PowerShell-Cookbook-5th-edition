# 2.9 - Working with Search Everything

# Run on SRV1 after installiung the Search Everything service


# 1. Getting download Locations
$ELoc  = 'https://www.voidtools.com/downloads'
$Release = Invoke-WebRequest -Uri $ELoc # Get all
$FLoc  = 'https://www.voidtools.com'
$EPath = $FLOC + ($Release.Links.href |
           Where-Object { $_ -match 'x64' } |
             Select-Object -First 1)
$EFile = 'C:\Foo\EverythingSetup.exe'

# 2. Downloading the Everything installer
Invoke-WebRequest -Uri $EPath -OutFile $EFile

# 3. Installing Everything
$Iopt = "-install-desktop-shortcut -install-service"
$Iloc = 'C:\Program Files\Everything'
 & $EFile --% /S -install-options  $Iipt /D=$Iopt

# 4. Opening the GUI for the first time
& "C:\Program Files\Everything\Everything.exe"

# 5. Finding the PSEverything module
Find-Module -Name PSEverything

# 6. Installing the module
Install-Module -Name PSEverything -Force

# 7. Discovering commands in the module
Get-Command -Module PSEverything

# 8. Getting a count of files in folders below C:\Foo
Set-Location -Path C:\Foo   # just in case
Search-Everything | 
  Get-Item  | 
    Group-Object DirectoryName | 
      Where-Object name -ne '' |
        Format-Table -Property Name, Count

# 9. Finding PowerShell scripts using wild cards
Search-Everything *.ps1 |
  Measure-Object
  
# 10. Finding all PowerShell scripts using regular expression
Search-Everything -RegularExpression '\.ps1$' -Global |
  Measure-Object






