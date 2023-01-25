# Recipe 11.11 - Managing VM Checkpoints

# Run on HV1 with PSDirect running


# 1. Ensuring PSDirect VM is running 
$VMState = Get-VM -VMName PSDirect | Select-Object -ExpandProperty State
If ($VMState -eq 'Off') {
  Start-VM -VMName PSDirect
}

# 2. Creating credentials for PSDirect
$RKAdmin     = 'Wolf\Administrator'
$Pass        = 'Pa$$w0rd'
$RKPassword  = 
    ConvertTo-SecureString -String $Pass -AsPlainText -Force
$RKCred = [System.Management.Automation.PSCredential]::new(
    $RKAdmin,$RKPassword)

# 3. Examining the C:\ in the PSDirect VM before we start
$ScriptBlock = { Get-ChildItem -Path C:\ | Format-Table}
$InvocationHT = @{
  VMName      = 'PSDirect'
  ScriptBlock = $ScriptBlock
  Credential  = $RKCred
}
Invoke-Command @InvocationHT

# 4. Creating a checkpoint of PSDirect on HV1
$CPHT = @{
  VMName       = 'PSDirect'
  ComputerName = 'HV1'
  SnapshotName = 'Snapshot1'
}
Checkpoint-VM @CPHT

# 5. Examining the files created to support the checkpoints
$Parent = Split-Path -Parent (Get-VM -Name PSdirect |
            Select-Object -ExpandProperty HardDrives).Path |
              Select-Object -First 1
Get-ChildItem -Path $Parent

# 6. Creating some content in a file on PSDirect and displaying it
$ScriptBlock = {
  $FileName1 = 'C:\File_After_Checkpoint_1'
  Get-Date | Out-File -FilePath $FileName1
  Get-Content -Path $FileName1
}
$InvocationHT = @{
  VMName      = 'PSDirect'
  ScriptBlock = $ScriptBlock
  Credential  = $RKCred
}
Invoke-Command @InvocationHT 

# 7. Taking a second checkpoint
$SecondChkpointHT = @{
  VMName        = 'PSDirect'
  ComputerName  = 'HV1'  
  SnapshotName  = 'Snapshot2'
}
Checkpoint-VM @SecondChkpointHT

# 8. Viewing the VM checkpoint details for PSDirect
Get-VMSnapshot -VMName PSDirect

# 9. Looking at the files supporting the two checkpoints
Get-ChildItem -Path $Parent

# 10. Creating and displaying another file in PSDirect
#    (i.e. after you have taken Snapshot2)
$ScriptBlock2 = {
  $FileName2 = 'C:\File_After_Checkpoint_2'
  Get-Date | Out-File -FilePath $FileName2
  Get-ChildItem -Path C:\ -File | Format-Table 
}
$InvocationHT2 = @{
  VMName    = 'PSDirect'
  ScriptBlock = $ScriptBlock2
  Credential  = $RKCred
}
Invoke-Command @InvocationHT2

# 11. Restoring the PSDirect VM back to the checkpoint named Snapshot1
$Snap1 = Get-VMSnapshot -VMName PSDirect -Name Snapshot1
Restore-VMSnapshot -VMSnapshot $Snap1 -Confirm:$false
Start-VM -Name PSDirect
Wait-VM -For IPAddress -Name PSDirect

# 12. Seeing what files we have now on PSDirect
$ScriptBlock3 = {
  Get-ChildItem -Path C:\ | Format-Table
}
$InvocationHT3 = @{
  VMName     = 'PSDirect'
  ScriptBlock = $ScriptBlock3
  Credential  = $RKCred
}
Invoke-Command @InvocationHT3

# 13. Rolling forward to Snapshot2
$Snap2 = Get-VMSnapshot -VMName PSdirect -Name Snapshot2
Restore-VMSnapshot -VMSnapshot $Snap2 -Confirm:$false
Start-VM -Name PSDirect
Wait-VM -For IPAddress -Name PSDirect

# 14. Observe the files you now have supporting PSDirect
$ScriptBlock4 = {
    Get-ChildItem -Path C:\ | Format-Table
}
$InvocationHT4 = @{
  VMName      = 'PSDirect'
  ScriptBlock = $ScriptBlock4 
  Credential  = $RKCred
}
Invoke-Command @InvocationHT4


# 15. Restoring to Snapshot1 again
$Snap1 = Get-VMSnapshot -VMName PSDirect -Name Snapshot1
Restore-VMSnapshot -VMSnapshot $Snap1 -Confirm:$false
Start-VM -Name PSDirect
Wait-VM -For IPAddress -Name PSDirect

# 16. Checking checkpoints and VM data files again
Get-VMSnapshot -VMName PSDirect
Get-ChildItem -Path $Parent | Format-Table

# 17. Removing all the checkpoints from HV1
Get-VMSnapshot -VMName PSDirect |
  Remove-VMSnapshot

# 18. Checking VM data files again
Get-ChildItem -Path $Parent