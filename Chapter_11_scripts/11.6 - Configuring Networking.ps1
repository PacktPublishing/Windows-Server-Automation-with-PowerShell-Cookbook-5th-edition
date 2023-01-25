# Recipe 11.6 - Configuring VM Networking
#
# Run on HV1

# 1. Setting the PSDirect VM's NIC
Get-VM PSDirect |
  Set-VMNetworkAdapter -MacAddressSpoofing On
  
# 2. Getting NIC details and any IP addresses from the PSDirect VM
Get-VMNetworkAdapter -VMName PSDirect

# 3. Creating a credential then getting VM networking details
$Administrator = 'localhost\Administrator'
$Password      = 'Pa$$w0rd'
$RKPassword = 
  ConvertTo-SecureString -String $Password -AsPlainText -Force
$RKCred     = [System.Management.Automation.PSCredential]::new(
                                            $Administrator,
                                            $RKPassword)
$VMHT = @{
    VMName      = 'PSDirect'
    ScriptBlock = {ipconfig}
    Credential  = $RKCred
}
Invoke-Command @VMHT 

# 4. Creating a virtual switch on HV1
$VirtSwitchHT = @{
    Name           = 'Internal'
    NetAdapterName = 'Ethernet'
    Notes          = 'Created on HV1'
}
New-VMSwitch @VirtSwitchHT

# 5. Connecting the PSDirect VM's NIC to the External switch
Connect-VMNetworkAdapter -VMName PSDirect -SwitchName Internal

# 6. Viewing VM networking information
Get-VMNetworkAdapter -VMName PSDirect

# 7. Observing the IP address in the PSDirect VM
$CommandHT = @{
    VMName      = 'PSDirect'
    ScriptBlock = {ipconfig}
    Credential  = $RKCred
}
Invoke-Command @CommandHT

# 8. Viewing the hostname on PSDirect
#    Reuse the hash table from step 6
$CommandHT.ScriptBlock = {hostname}
Invoke-Command @CommandHT

# 9. Changing the name of the host in the PSDirect VM
#    Reuse the hash table from steps 6,7
$CommandHT.ScriptBlock = {Rename-Computer -NewName Wolf -Force}
Invoke-Command @CommandHT

# 10. Rebooting and wait for the restarted POSDirect VM
Restart-VM -VMName PSDirect -Wait -For IPAddress -Force

# 11. Getting hostname of the PSDirect VM
$CommandHT.ScriptBlock = {HOSTNAME}
Invoke-Command @CommandHT