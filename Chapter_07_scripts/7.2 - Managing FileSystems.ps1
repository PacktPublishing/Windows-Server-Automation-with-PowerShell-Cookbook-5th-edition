# Recipe 7.2 - Managing Filesystems
#
# Run on SRV1
# SRV1, SRV2 has 8 extra disks that are 'bare' and just added to the VMs
# In recipe 7.1, you used the first 2, in this recipe you use the third.
# At this point disk 0 is the C:, Disk 1,2 were used in 7.1
# where you created the F, S: and T: volumes

# 1. Getting second disk
$Disk = Get-Disk | Select-Object -Skip 1 -First 1
$Disk | Format-List

# 2. Creating a new volume in this disk
$NewVolumeHT1   = @{
  DiskNumber    = $Disk.Disknumber
  DriveLetter  = 'S'
  FriendlyName = 'Files'
}
New-Volume @NewVolumeHT1

# 3. Getting next available disk to use on SRV1
$Disk2 = Get-Disk |
           Where-Object PartitionStyle -eq 'MBR' |
             Select-Object -First 1
$Disk2 | Format-List

# 4. Creating 4 new partitions on third (MBR) disk
$UseMaxHT= @{UseMaximumSize = $true}
New-Partition -DiskNumber $Disk2.DiskNumber -DriveLetter W -Size 1gb
New-Partition -DiskNumber $Disk2.DiskNumber -DriveLetter X -Size 15gb
New-Partition -DiskNumber $Disk2.DiskNumber -DriveLetter Y -Size 15gb
New-Partition -DiskNumber $Disk2.DiskNumber -DriveLetter Z @UseMaxHT

# 5. Formatting each partition
$FormatHT1 = @{
  DriveLetter        = 'W'
  FileSystem         = 'FAT'
  NewFileSystemLabel = 'w-fat'
}
Format-Volume @FormatHT1
$FormatHT2 = @{
  DriveLetter        = 'X'
  FileSystem         = 'exFAT'
  NewFileSystemLabel = 'x-exFAT'
}
Format-Volume @FormatHT2
$FormatHT3 = @{
  DriveLetter        = 'Y'
  FileSystem         = 'FAT32'
  NewFileSystemLabel = 'Y-FAT32'
}
Format-Volume  @FormatHT3
$FormatHT4 = @{
  DriveLetter        = 'Z'
  FileSystem         = 'ReFS'
  NewFileSystemLabel = 'Z-ReFS'
}
Format-Volume @FormatHT4

# 7. Getting all volumes on SRV1
Get-Volume | Sort-Object -Property DriveLetter
