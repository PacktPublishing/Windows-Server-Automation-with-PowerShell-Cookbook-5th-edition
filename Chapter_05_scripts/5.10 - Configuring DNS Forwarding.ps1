# 5.10 - Configure DNS Forwarding

# Run On DC1

# 1. Obtaining the IP addresses of DNS servers for Packt.Com
$NameServers = Resolve-DnsName -Name Packt.Com -Type NS | 
  Where-Object Name -eq 'Packt.Com'
$NameServers

# 2. Obtaining the IPV4 addresses for these hosts
$NameServerIPs = foreach ($Server in $NS) {
  (Resolve-DnsName -Name $Server.NameHost -Type A).IPAddress
}
$NameServerIPs

# 3. Adding conditional forwarder on DC1
$CFHT = @{
  Name          = 'Packt.Com'
  MasterServers = $NSIPS
}
Add-DnsServerConditionalForwarderZone @CFHT

# 4. Checking zone on DC1 
Get-DnsServerZone -Name Packt.Com

# 5. Testing conditional forwarding
Resolve-DNSName -Name WWW.Packt.Com -Server DC1 |
 Format-Table 