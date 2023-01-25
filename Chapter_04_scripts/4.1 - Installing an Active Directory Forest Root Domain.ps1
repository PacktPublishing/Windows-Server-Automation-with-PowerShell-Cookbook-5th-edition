# 4.1 - Installing an Active Directory Forest Root Domain  

# Run on DC1
# DC1 is initially a stand-alone work group server you convert
# into a DC with DNS.
# You should install DC1 with PowerShell and VSCode

# 1. Installing the AD Domain Services feature and management tools
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# 2. Importing the ADDeployment module
Import-Module -Name ADDSDeployment 

# 3. Examining the commands in the ADDSDeployment module
Get-Command -Module ADDSDeployment

# 4.	Creating a secure password for the Administrator
$PasswordHT = @{
  String      = 'Pa$$w0rd'
  AsPlainText = $true
  Force       = $true
}
$SecurePW = ConvertTo-SecureString @$PasswordHT

# 5. Testing DC Forest installation starting on DC1
$ForestHT = @{
  DomainName           = 'Reskit.Org'
  InstallDNS           = $true 
  NoRebootOnCompletion = $true
  SafeModeAdministratorPassword = $SecurePW
  ForestMode           = 'WinThreshold'
  DomainMOde           = 'WinThreshold'
}
Test-ADDSForestInstallation @ForestHT -WarningAction SilentlyContinue

# 6. Creating Forest Root DC on DC1
$NewActiveDirectoryParameterHashTable = @{
  DomainName                    = 'Reskit.Org'
  SafeModeAdministratorPassword = $PSS
  InstallDNS                    = $true
  DomainMode                    = 'WinThreshold'
  ForestMode                    = 'WinThreshold'
  Force                         = $true
  NoRebootOnCompletion          = $true
  WarningAction                 = 'SilentlyContinue'
}
Install-ADDSForest @$NewActiveDirectoryParameterHashTable

# 7. Checking key AD and related services
Get-Service -Name DNS, Netlogon

# 8. Checking DNS zones
Get-DnsServerZone

# 9. Restarting DC1 to complete promotion
Restart-Computer -Force

