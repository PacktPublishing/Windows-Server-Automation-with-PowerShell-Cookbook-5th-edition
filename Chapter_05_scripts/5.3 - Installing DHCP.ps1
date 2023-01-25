# 5.3 - Installing and Authorizing DC1 as a DHCP server
#
# Run on DC1 after AD setup 

# 1. Installing the DHCP feature on DC1 and adding the management tools
Import-Module -Name ServerManager -WarningAction SilentlyContinue
Install-WindowsFeature -Name DHCP -IncludeManagementTools

# 2. Adding DC1 to trusted DHCP servers and adding the 
#    DHCP security group
Import-Module -Name DHCPServer -WarningAction SilentlyContinue
Add-DhcpServerInDC
Add-DHCPServerSecurityGroup 

# 3. Letting DHCP know it is fully configured
$DHCPHT = @{
  Path  = 'HKLM:\SOFTWARE\Microsoft\ServerManager\Roles\12'
  Name  = 'ConfigurationState'
  Value = 2
}
Set-ItemProperty @DHCPHT

# 4. Restarting DHCP server 
Restart-Service -Name DHCPServer -Force 

# 5. Testing service availability
Get-Service -Name DHCPServer | 
  Format-List -Property *