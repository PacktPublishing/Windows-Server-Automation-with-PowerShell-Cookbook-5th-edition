# 1.1 Install PowerShell 7.2
#
# Run on SRV1
# Run using an elevated Windows PowerShell 5.1 ISE

# 1. Setting Execution Policy for Windows PowerShell
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force

# 2. Update help text for Windows PowerShell
Update-Help -Force |
  Out-Null

# 3. Ensuring the C:\Foo Folder exists
$LFHT = @{
  ItemType    = 'Directory'
  ErrorAction = 'SilentlyContinue' # should it already exist
}
New-Item -Path C:\Foo @LFHT | Out-Null

# 4. Download PowerShell 7 installation script from Github
Set-Location -Path C:\Foo
$URI = 'https://aka.ms/install-powershell.ps1'
Invoke-RestMethod -Uri $URI |
  Out-File -FilePath C:\Foo\Install-PowerShell.ps1

# 5. Viewing Installation Script Help
Get-Help -Name C:\Foo\Install-PowerShell.ps1

# 6. Installing PowerShell 7.2
$EXTHT = @{
  UseMSI                 = $true
  Quiet                  = $true
  AddExplorerContextMenu = $true
  EnablePSRemoting       = $true
}
C:\Foo\Install-PowerShell.ps1 @EXTHT | Out-Null

# 7. Installing the preview and daily builds (for the adventurous)
C:\Foo\Install-PowerShell.ps1 -Preview -Destination C:\PSPreview |
  Out-Null
C:\Foo\Install-PowerShell.ps1 -Daily   -Destination C:\PSDailyBuild |
  Out-Null

# 8. Creating Windows PowerShell ISE and console default profiles
# First create the  ISE
$Uri = 'https://raw.githubusercontent.com/doctordns/PacktPS72/master/' +
       'Scripts/Goodies/Microsoft.PowerShell_Profile.ps1'
$ProfileFile    = $Profile.CurrentUserCurrentHost
New-Item -Path $ProfileFile -Force -WarningAction SilentlyContinue |
   Out-Null
(Invoke-WebRequest -Uri $Uri -UseBasicParsing).Content |
  Out-File -FilePath  $ProfileFile
# Now profile for ConsoleHost
$ProfilePath    = Split-Path -Path $ProfileFile
$ChildPath      = 'Microsoft.PowerShell_profile.ps1'
$ConsoleProfile = Join-Path -Path $ProfilePath -ChildPath $ChildPath
(Invoke-WebRequest -Uri $URI -UseBasicParsing).Content |
  Out-File -FilePath  $ConsoleProfile

# 9. Checking versions of PowerShell 7 loaded
Get-ChildItem -Path C:\pwsh.exe -Recurse -ErrorAction SilentlyContinue
