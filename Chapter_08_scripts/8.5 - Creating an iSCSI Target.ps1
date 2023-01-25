# 10.5 - Creating an iSCSI Target

# Run from SS1 as Reskit\Administrator

# 1. Installing the iSCSI target feature on SS1
Import-Module -Name ServerManager -WarningAction SilentlyContinue
Install-WindowsFeature FS-iSCSITarget-Server

# 2. Restart the computer
Restart-Computer

# 3. Exploring iSCSI target server settings
Get-IscsiTargetServerSetting

# 4. Creating a folder on SS1 to hold the iSCSI virtual disk
$NewFolderHT = @{
  Path        = 'C:\iSCSI' 
  ItemType    = 'Directory'
  ErrorAction = 'SilentlyContinue'
}
New-Item @NewFolderHT | Out-Null

# 5. Creating an iSCSI virtual disk (aka a LUN)
$VDiskPath = 'C:\iSCSI\ITData.Vhdx'
$VDHT = @{
   Path        = $VDiskPath
   Description = 'LUN For IT Group'
   SizeBytes   = 500MB
 }
New-IscsiVirtualDisk @VDHT

# 6. Setting the iSCSI target, specifying who can initiate an iSCSI connection
$TargetName = 'ITTarget'
$NewTargetHT = @{
  TargetName   = $TargetName
  InitiatorIds = 'IQN:*'
}
New-IscsiServerTarget @NewTargetHT

# 7. Creating iSCSI disk target mapping LUN name to a local path
$TargetHT = @{
  TargetName = $TargetName
  Path       = $VDiskPath
}
Add-IscsiVirtualDiskTargetMapping @TargetHT






# For testing and Undo:

$LP = 'C:\iSCSI\ITData.Vhdx'
Get-IscsiServerTarget | Remove-IscsiServerTarget
Get-IscsiVirtualDisk | Remove-IscsiVirtualDisk
Remove-item $LP
