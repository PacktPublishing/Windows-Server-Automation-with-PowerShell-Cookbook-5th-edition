# 5.6 Creating a DHCP Reservation

# Run on DC1, after DHCP Server service added and 10.10.10.0 scope created.


# 1. Importing the DHCP Server module explicitly
Import-Module -Name DHCPServer

# 2. Getting NIC's MAC Address for NIC in SRV2
$SB = {Get-NetAdapter -Name Ethernet}
$Nic = Invoke-command -ComputerName SRV2 -ScriptBlock $SB
$MAC = $Nic.MacAddress
$MAC

# 3. Creating a DHCP Reservation for SRV2
$NewResHT = @{
  ScopeId      = '10.10.10.0'
  IPAddress    = '10.10.10.199'
  ComputerName = 'DC1'
  ClientId  = $Mac
}
Add-DhcpServerv4Reservation @NewResHT

# 4. Renewing IP address in SRV2
Invoke-Command -ComputerName SRV2 -ScriptBlock {
    IPConfig /renew
} 

# 5.Testing net connection to SRV2
Clear-DnsClientCache 
Resolve-DnsName -Name SRV2.Reskit.Org -Type A
Test-Connection -TargetName SRV2.Reskit.Org
