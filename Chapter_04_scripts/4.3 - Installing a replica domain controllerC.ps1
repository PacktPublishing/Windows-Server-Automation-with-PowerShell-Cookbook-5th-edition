# 4.3 - Installing a Replica DC

# Run this recipe on DC2 once DC1 has been promoted to be a DC
# Needs new DC2 VM as domain joined host in Reskit domain
# Login as Reskit\Administrator
# DC1 is online and is the forest root DC

# 1. Importing the Server Manager module
Import-Module -Name ServerManager -WarningAction SilentlyContinue

# 2. Checking DC1 can be resolved 
Resolve-DnsName -Name DC1.Reskit.Org -Type A

# 3. Testing the network connection to DC1
Test-NetConnection -ComputerName DC1.Reskit.Org -Port 445
Test-NetConnection -ComputerName DC1.Reskit.Org -Port 389

# 4. Adding the AD DS features on DC2
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# 5. Promoting DC2 to be a DC
Import-Module -Name ADDSDeployment -WarningAction SilentlyContinue
$User       = "Administrator@Reskit.Org" 
$Password   = 'Pa$$w0rd'
$PWSString  = ConvertTo-SecureString -String $Password -AsPlainText -Force
$CredRK = [PSCredential]::New($User,$PWSString)
$INSTALLHT = @{
  DomainName                    = 'Reskit.Org'
  SafeModeAdministratorPassword = $PSS
  SiteName                      = 'Default-First-Site-Name'
  NoRebootOnCompletion          = $true
  InstallDNS                    = $false
  Credential                    = $CredRK
  Force                         = $true
} 
Install-ADDSDomainController @INSTALLHT | Out-Null

# 6. Checking the computer objects in AD
Get-ADComputer -Filter *  | 
  Format-Table DNSHostName, DistinguishedName

# 7. Rebooting DC2 manually
Restart-Computer -Force

###  DC2 reboots at this point
### Relogon as Reskit\Adminstrator

# 8. Checking DCs in Reskit.Org
$SearchBase = 'OU=Domain Controllers,DC=Reskit,DC=Org'
Get-ADComputer -Filter * -SearchBase $SearchBase  -Properties * |
  Format-Table -Property DNSHostName, Enabled

# 9. Viewing Reskit.Org domain DCs
Get-ADDomain |
  Format-Table -Property Forest, Name, 
                         ReplicaDirectoryServers
