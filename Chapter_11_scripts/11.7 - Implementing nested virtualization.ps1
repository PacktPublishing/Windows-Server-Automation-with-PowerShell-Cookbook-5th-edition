# Recipe 11.7 - Implementing nested virtualization
#
# Run on HV1

#  1. Stopping the PSDirect VM
Stop-VM -VMName PSDirect

# 2. Setting the VM's processor to support virtualization
$VMHT = @{
  VMName                         = 'PSDirect' 
  ExposeVirtualizationExtensions = $true
}
Set-VMProcessor @VMHT
Get-VMProcessor -VMName PSDirect |
  Format-Table -Property Name, Count,
                         ExposeVirtualizationExtensions

# 3. Starting the PSDirect VM
Start-VM -VMName PSDirect
Wait-VM  -VMName PSDirect -For Heartbeat
Get-VM   -VMName PSDirect

# 4. Creating credentials for PSDirect
$User = 'Wolf\Administrator'  
$PasswordHT = @{
  String      = 'Pa$$w0rd'
  AsPlainText = $true
  Force       = $true
}
$SecurePW  = ConvertTo-SecureString @PasswordHT
$Cred = [System.Management.Automation.PSCredential]::new(
                                               $User, $SecurePW)

# 5. Creating a script block for remote execution
$ScriptBlock = {
  Install-WindowsFeature -Name Hyper-V -IncludeManagementTools
}

# 6. Creating a remoting session to PSDirect
$Session = New-PSSession -VMName PSDirect -Credential $Cred

# 7. Installing Hyper-V inside PSDirect
$InstallHT = @{
  Session     = $Session
  ScriptBlock = $ScriptBlock
}
Invoke-Command @InstallHT

# 8. Restarting the VM to finish adding Hyper-V to PSDirect
Stop-VM  -VMName PSDirect
Start-VM -VMName PSDirect
Wait-VM  -VMName PSDirect -For IPAddress
Get-VM   -VMName PSDirect

# 9. Creating a nested VM inside the PSDirect VM
$ScriptBlock2 = {
        $VMName = 'NestedVM'
        New-VM -Name $VMName -MemoryStartupBytes 1GB | Out-Null
        Get-VM
}
$InstallHT2 = @{
  VMName = 'PSDirect'
  ScriptBlock = $ScriptBlock2
}
Invoke-Command @InstallHT2 -Credential $Cred

