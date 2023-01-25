# 7.4 - Managing Storage Replica
#
# Run on SRV1, with SRV2, DC1 online

# 1. Getting disk number of the disk holding the S partition
$Part = Get-Partition -DriveLetter S
"S drive on disk [$($Part.DiskNumber)]"

# 2. Creating S: drive on SRV2
$ScriptBlock = {
  Initialize-Disk -Number $using:Part.DiskNumber -PartitionStyle GPT
  $NewVolHT = @{
   DiskNumber   =  $using:Part.DiskNumber
    FriendlyName = 'Files'
    FileSystem   = 'NTFS'
    DriveLetter  = 'S'
  }
  New-Volume @NewVolHT
}
Invoke-Command -ComputerName SRV2 -ScriptBlock $ScriptBlock

# 3. Creating content on S: on SRV1
1..100 | ForEach-Object {
  $NewFldr = "S:\CoolFolder$_"
  New-Item -Path $NewFldr -ItemType Directory | Out-Null
  1..100 | ForEach-Object {
    $NewFile = "$NewFldr\CoolFile$_"
    "Cool File" | Out-File -PSPath $NewFile
  }
}

# 4. Counting files/folders on S:
Get-ChildItem -Path S:\ -Recurse | Measure-Object

# 5. Examining the S: drive remotely on SRV2
$ScriptBlock2 = {
  Get-ChildItem -Path S:\ -Recurse |
    Measure-Object
}
Invoke-Command -ComputerName SRV2 -ScriptBlock $ScriptBlock2

# 6. Adding the storage replica feature to SRV1
Add-WindowsFeature -Name Storage-Replica -IncludeManagementTools |
  Out-Null

# 7. Adding the Storage Replica Feature to SRV2
$SB= {
  Add-WindowsFeature -Name Storage-Replica | Out-Null
}
Invoke-Command -ComputerName SRV2 -ScriptBlock $SB

# 8. Restarting SRV2 and waiting for the restart
$RSHT = @{
  ComputerName = 'SRV2'
  Force        = $true
}
Restart-Computer @RSHT -Wait -For WinRM

# 9. Restarting SRV1 to finish the installation process
Restart-Computer

# 10. Creating a G: volume in disk 3 on SRV1
$ScriptBlock3 = {
  Initialize-Disk -Number 3 -PartitionStyle GPT | Out-Null
  $VolumeHT = @{
   DiskNumber   =  3
   FriendlyName = 'SRLOGS'
   DriveLetter  = 'G'
  }
  New-Volume @VolumeHT
}
Invoke-Command -ComputerName SRV1 -ScriptBlock $ScriptBlock3

# 11. Creating G: volume on SRV2
Invoke-Command -ComputerName SRV2 -ScriptBlock $ScriptBlock3

# 12. Viewing volumes on SRV1
Get-Volume | Sort-Object -Property Driveletter

# 13. Viewing volumes on SRV2
Invoke-Command -Computer SRV2 -ScriptBlock {
    Get-Volume | Sort-Object -Property Driveletter
}

# 14. Creating an SR replica partnership
$NewSRHT =  @{
  SourceComputerName       = 'SRV1'
  SourceRGName             = 'SRV1RG1'
  SourceVolumeName         = 'S:'
  SourceLogVolumeName      = 'G:'
  DestinationComputerName  = 'SRV2'
  DestinationRGName        = 'SRV2RG1'
  DestinationVolumeName    = 'S:'
  DestinationLogVolumeName = 'G:'
  LogSizeInBytes           = 2gb
}
New-SRPartnership @NewSRHT


# 15. Examining the volumes on SRV2
$ScriptBlock3 = {
  Get-Volume |
    Sort-Object -Property DriveLetter |
      Format-Table}
Invoke-Command -ComputerName SRV2 -ScriptBlock $ScriptBlock3

# 16. Reversing the replication
$ReverseHT = @{
  NewSourceComputerName   = 'SRV2'
  SourceRGName            = 'SRV2RG1'
  DestinationComputerName = 'SRV1'
  DestinationRGName       = 'SRV1RG1'
  Confirm                 = $false
}
Set-SRPartnership @ReverseHT

# 17. Viewing the SR Partnership
Get-SRPartnership

# 18. Examining the files remotely on SRV2
$ScriptBlock4 = {
  Get-ChildItem -Path S:\ -Recurse |
    Measure-Object
}
Invoke-Command -ComputerName SRV2 -ScriptBlock $ScriptBlock4
