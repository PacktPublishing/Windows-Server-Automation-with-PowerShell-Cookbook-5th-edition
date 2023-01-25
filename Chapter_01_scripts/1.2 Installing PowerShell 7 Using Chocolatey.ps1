# 1.2 Install PowerShell 7 using Chocolatey
#
# Run on SRV1
# Run after running 1.1 to create C:\Foo.
# Run using an elevated Windows PowerShell 5.1 ISE

# 1. Downloading the installation script for Chocolatey
$ChocoIns = 'C:\Foo\Install-Chocolatey.ps1'
$DI       = New-Object System.Net.WebClient
$DI.DownloadString('https://community.chocolatey.org/install.ps1') |
  Out-File -FilePath $ChocoIns

# 2. Viewing the installation help file
C:\Foo\Install-Chocolatey.ps1 -?

# 3. Install Chocolatey
C:\Foo\Install-Chocolatey.ps1

# 4. Configure Chocolatey
choco feature enable -n allowGlobalConfirmation

# 5. Find PowerShell (PWSH) on Chocolatey
choco find pwsh

# 6. Install PowerShell-7 using coco.exe
choco install powershell-core --force
