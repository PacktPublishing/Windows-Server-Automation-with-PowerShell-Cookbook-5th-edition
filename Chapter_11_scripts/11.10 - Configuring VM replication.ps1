# Recipe 12.10 - Configuring VM replication

# Run on HV1, with HV2, DC1 and DC2 online

# 1. Configuring HV1 and HV2 to be trusted for delegation in AD on DC1
$ScriptBlock = {
  Set-ADComputer -Identity HV1 -TrustedForDelegation $True
  Set-ADComputer -Identity HV2 -TrustedForDelegation $True
}
Invoke-Command -ComputerName DC1 -ScriptBlock $ScriptBlock

# 2. Rebooting the HV1 and HV2 hosts
Restart-Computer -ComputerName HV2 -Force
Restart-Computer -ComputerName HV1 -Force

# 3. Configuring Hyper-V replication on HV1 and HV2
$VMReplHT = @{
  ReplicationEnabled              = $true
  AllowedAuthenticationType       = 'Kerberos'
  KerberosAuthenticationPort      = 42000
  DefaultStorageLocation          = 'C:\Replicas'
  ReplicationAllowedFromAnyServer = $true
  ComputerName                    = 'HV1.Reskit.Org',
                                    'HV2.Reskit.Org'
}
Set-VMReplicationServer @VMReplHT

# 4. Enabling PSDirect on HV1 to be a replica source
$VMReplicaSourceHT = @{
  VMName             = 'PSDirect'
  Computer           = 'HV1'
  ReplicaServerName  = 'HV2'
  ReplicaServerPort  = 42000
  AuthenticationType = 'Kerberos'
  CompressionEnabled = $true
  RecoveryHistory    = 5
}
Enable-VMReplication  @VMReplicaSourceHT -Verbose

# 5. Viewing the replication status of HV1
Get-VMReplicationServer -ComputerName HV1

# 6. Checking PSDirect on Hyper-V hosts
Get-VM -ComputerName HV1 -VMName PSDirect
Get-VM -ComputerName HV2 -VMName PSDirect

# 7. Starting the initial replication
Start-VMInitialReplication -VMName PSDirect -ComputerName HV1

# 8. Examining the initial replication state on HV1 just after
#    you start the initial replication
Measure-VMReplication -ComputerName HV1

# 9. Examining the replication status on HV1 after replication completes
Measure-VMReplication -ComputerName HV1

# 10. Testing PSDirect failover to HV2
$FOScriptBlock = {
  $VM = Start-VMFailover -AsTest -VMName PSDirect -Confirm:$false
  Start-VM $VM
}
Invoke-Command -ComputerName HV2 -ScriptBlock $FOScriptBlock

# 11. Viewing the status of PSDirect VMs on HV2
$VMsOnHV1 = Get-VM -ComputerName HV2 -VMName PSDirect*
$VMsOnHV1

# 12. Examining networking on PS DIrtect Test VM
$TestVM = $VMsOnHV1 | Where-Object Name -Match 'Test'
Get-VMNetworkAdapter -CimSession HV2 -VMName $TestVM.Name

# 13. Stopping the failover test
$StopScriptBlock = {
  Stop-VMFailover -VMName PSDirect
}
Invoke-Command -ComputerName HV2 -ScriptBlock $StopScriptBlock

# 14. Viewing the status of VMs on HV1 and HV2 after failover stopped
Get-VM -ComputerName HV1 -VMName PSDirect*
Get-VM -ComputerName HV2 -VMName PSDirect*

# 15. Stopping VM1 on HV1 before performing a planned failover
Stop-VM PSDirect -ComputerName HV1

# 16. Starting VM failover from HV1 to HV2
Start-VMFailover -VMName PSDirect -ComputerName HV2 -Confirm:$false

# 17. Completing the failover
$CHT = @{
  VMName       = 'PSDIrect'
  ComputerName = 'HV2'
  Confirm      = $false
}
Complete-VMFailover @CHT

# 18. Viewing VM Status on both Hyper-V Hosts
Get-VM -ComputerName HV1 -VMName PSDirect*
Get-VM -ComputerName HV2 -VMName PSDirect*

# 19. Starting the replicated VM on HV2
Start-VM -VMname PSDirect -ComputerName HV2

# 20. Checking PSDirect VM networking for HV2
Get-VMNetworkAdapter -ComputerName HV2 -VMName PSDirect

# 21. Connecting PSDirect to VM Switch
$ConnectHT = @{
  VMName       = 'PSDirect'
  ComputerName = 'HV2'
  SwitchName   = 'Internal'
}
Connect-VMNetworkAdapter @ConnectHT

# 21. Checking PSDirect VM networking for HV2 
Get-VMNetworkAdapter -ComputerName HV2 -VMName PSDirect

