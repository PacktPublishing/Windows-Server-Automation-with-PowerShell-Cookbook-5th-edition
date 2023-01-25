# 7.5 Deploying Storage Spaces
#
# Run on SRV1
# Uses 5 disks added earlier


# 1. Viewing disks available for pooling
$Disks = Get-PhysicalDisk -CanPool $true
$Disks | Sort-Object -Property Deviceid

# 2. Creating a storage pool
$NewPoolHT = @{
  FriendlyName                 = 'RKSP'
  StorageSubsystemFriendlyName = "Windows Storage*"
  PhysicalDisks                = $Disks
}
New-StoragePool @NewPoolHT

# 3. Creating a mirrored hard disk named Mirror1
$VDisk1HT = @{
  StoragePoolFriendlyName   = 'RKSP'
  FriendlyName              = 'Mirror1'
  ResiliencySettingName     = 'Mirror'
  Size                      = 8GB
  ProvisioningType          = 'Thin'
}
New-VirtualDisk @VDisk1HT

# 4. Creating a three way mirrored disk named Mirror2
$VDisk2HT = @{
  StoragePoolFriendlyName    = 'RKSP'
  FriendlyName               = 'Mirror2'
  ResiliencySettingName      = 'Mirror'
  NumberOfDataCopies         = 3
  Size                       = 8GB
  ProvisioningType           = 'Thin'
}
New-VirtualDisk @VDisk2HT

# 5. Creating a volume in Mirror1
Get-VirtualDisk  -FriendlyName 'Mirror1' |
  Get-Disk |
    Initialize-Disk -PassThru |
      New-Partition -AssignDriveLetter -UseMaximumSize |
        Format-Volume

# 6. Creating a volume in Mirror2
Get-VirtualDisk  -FriendlyName 'Mirror2' |
  Get-Disk |
    Initialize-Disk -PassThru |
      New-Partition -AssignDriveLetter -UseMaximumSize |
        Format-Volume

# 7.  Viewing volumes on SRV1
Get-Volume | Sort-Object -Property DriveLetter