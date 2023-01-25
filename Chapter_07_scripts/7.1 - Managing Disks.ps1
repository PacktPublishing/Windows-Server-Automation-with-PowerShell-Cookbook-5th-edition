# Recipe 7.1 - Managing Disks
#
# Run on SRV1
# SRV1, SRV2 has 8 extra disks that are 'bare' and just added to the VM

# 0. Add new disks to the SRV1, SRV2 VMs
# Run this step on VM host
# Assumes a single C:, and SCSI bus 0 is unoccupied.
# This step creates a new SCSI COntroller as well as 8 new disks.

# 0.1 Turning off the VMs
Get-VM -Name SRV1, SRV2 | Stop-VM -Force

# 0.2 Getting Path for hard disks for SRV1, SRV2
$Path1   = Get-VMHardDiskDrive -VMName SRV1
$Path2   = Get-VMHardDiskDrive -VMName SRV2
$VMPath1 = Split-Path -Parent $Path1.Path
$VMPath2 = Split-Path -Parent $Path2.Path

# 0.3 Creating 8 virtual disks on VM host
0..7 | ForEach-Object {
  New-VHD -Path $VMPath1\SRV1-D$_.vhdx -SizeBytes 64gb -Dynamic |
    Out-Null
  New-VHD -Path $VMPath2\SRV2-D$_.vhdx -SizeBytes 64gb -Dynamic |
    Out-Null
}

# 0.4 Adding disks to SRV1, SRV2
# Create Next controller on SRV1/SRV2
Add-VMScsiController -VMName SRV1
[int] $SRV1Controller =
  Get-VMScsiController -VMName SRV1 |
    Select-Object -Last 1 |
      Select-Object -ExpandProperty ControllerNumber
Add-VMScsiController -VMName SRV2
[int] $SRV2Controller =
  Get-VMScsiController -VMName SRV1 |
    Select-Object -Last 1 |
       Select-Object -ExpandProperty ControllerNumber

# Now add the disks to each VM
0..7 | ForEach-Object {
  $DHT1 = @{
    VMName           = 'SRV1'
    Path             = "$VMPath1\SRV1-D$_.vhdx"
    ControllerType   = 'SCSI'
    ControllerNumber = $SRV1Controller
  }
  $DHT2 = @{
    VMName           = 'SRV2'
    Path             =  "$VMPath2\SRV2-D$_.vhdx"
    ControllerType   = 'SCSI'
    ControllerNumber =  $SRV2Controller
  }
  Add-VMHardDiskDrive @DHT1
  Add-VMHardDiskDrive @DHT2
}

# 0.5 Checking VM disks for SRV1, SRV2
Get-VMHardDiskDrive -VMName SRV1 | Format-Table
Get-VMHardDiskDrive -VMName SRV2 | Format-Table

# 0.6 Restarting VMs
Start-VM -VMName SRV1
Start-VM -VMName SRV2

#
# Run remainder of this recipe on SRV1 once
# SRV1 and SRV2 have fully rebooted.

# 1. Displaying the disks on SRV1
Get-Disk


# 2. Get first usable disk
$Disk = Get-Disk |
           Where-Object PartitionStyle -eq Raw |
             Select-Object -First 1
$Disk | Format-List

# 3. Initializing the first available disk
$Disk |
  Initialize-Disk -PartitionStyle GPT

# 4. Re-displaying all disks in SRV1
Get-Disk

# 5. Viewing volumes on SRV1
Get-Volume | Sort-Object -Property DriveLetter

# 6. Viewing partitions on SRV1
Get-Partition

# 7. Examining details of a volume
Get-Volume | Select-Object -First 1 | Format-List

# 8. Examining details of a partition
Get-Partition | Select-Object -First 1 | Format-List

# 9. Formatting and initialization second disk as MBR
$Disk2 = Get-Disk |
           Where-Object PartitionStyle -eq Raw |
             Select-Object -First 1
$Disk2 |
  Initialize-Disk -PartitionStyle MBR

# 10. Examining disks in SRV1
Get-Disk




# For testing - this code removes disks from VMs
# After running this code, you can re=run step 0 to start over

# Run on Hyper-V host
Get-VM -Name SRV1, SRV2 | Stop-VM -Force
"VMs stopped"
$Path1   = Get-VMHardDiskDrive -VMName SRV1
$Path2   = Get-VMHardDiskDrive -VMName SRV2
$VMPath1 = Split-Path -Parent $Path1.Path | Select-Object -First 1
$VMPath2 = Split-Path -Parent $Path2.Path | Select-Object -First 1

$Disks1 = $Path1 | Where-Object {$_.Path -match '-D'}
$Disks2 = $Path2 | Where-Object {$_.Path -match '-D'}
"Found Disks"
# remove disks from SRV1
foreach ($Disk in $Disks1) {
  $DHT = @{
    Controllertype     = $Disk.ControllerType
    ControllerNumber   = $Disk.ControllerNumber
    ControllerLocation = $Disk.ControllerLocation
  }
  Remove-VMHardDiskDrive @DHT -VMName SRV1
}
"Disks removed from SRV1"
# remove disks from SRV2
foreach ($Disk in $Disks2) {
  $DHT = @{
    Controllertype     = $Disk.ControllerType
    ControllerNumber   = $Disk.ControllerNumber
    ControllerLocation = $Disk.ControllerLocation
  }
  Remove-VMHardDiskDrive @DHT -VMName SRV2
}
"Disks removed from SRV2"
# Remove VHDs

Get-ChildItem -Path $VMPath1\*-d*  | Remove-Item
Get-ChildItem -Path $VMPath2\*-d*  | Remove-Item
"VHDX files purged"




