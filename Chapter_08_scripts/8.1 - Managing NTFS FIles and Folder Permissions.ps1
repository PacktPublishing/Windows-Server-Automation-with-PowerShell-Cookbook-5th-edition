# Recipe 10.1 - Managing NTFS Permissions
# 
# Run on FS1 - After creating a new Disk 1.

# 0. Adding disk to the VM
# 0.1 Stopping VM
Get-VM -Name FS1 | Stop-VM -Force

# 0.2 Getting Path for hard disks for SRV1, SRV2
$Path1   = Get-VMHardDiskDrive -VMName FS1
$VMPath1 = Split-Path -Parent $Path1.Path 

# 0.3 Creating a new VHDX
New-VHD -Path $VMPath1\FS1-F.vhdx -SizeBytes 64gb -Dynamic 

# 0.4 Add a new SCSI controller to FS1
Add-VMScsiController -VMName FS1 
[int] $FS1Controller = 
  Get-VMScsiController -VMName FS1 | 
    Select-Object -Last 1 | 
      Select-Object -ExpandProperty ControllerNumber


# 0.5 Add the VHDX to the VM
$DiskHT = @{
  VMName           = 'FS1' 
  Path             =  "$VMPath1\FS1-F.vhdx"
  ControllerType   = 'SCSI' 
  ControllerNumber =  $FS1Controller
}
Add-VMHardDiskDrive @DiskHT

# 0.6 restart the VM
Start-VM -Name FS1

# Wait until FS1 is up and running then, run the 
# remainder of this script on FS1.

# 1. Getting and initializing the new disk and creating an F: volume
$Disk = Get-Disk |
           Where-Object PartitionStyle -eq Raw |
             Select-Object -First 1
$Disk | 
  Initialize-Disk -PartitionStyle GPT
$NewVolumeHT1   = @{
  DiskNumber    = $Disk.DiskNumber 
  DriveLetter  = 'F'
  FriendlyName = 'FS Files'
}
New-Volume @NewVolumeHT1 | Out-Null

# 2. Downloading the NTFSSecurity module from PSGallery
Install-Module NTFSSecurity -Force

# 3. Getting commands in the module
Get-Command -Module NTFSSecurity 

# 4. Creating a new folder and a file in the folder
New-Item -Path F:\Secure1 -ItemType Directory |
    Out-Null
"Secure" | Out-File -FilePath F:\Secure1\Secure.Txt
Get-ChildItem -Path F:\Secure1

# 5. Viewing ACL of the folder
Get-NTFSAccess -Path F:\Secure1 |
  Format-Table -AutoSize

# 6. Viewing ACL of the file
Get-NTFSAccess F:\Secure1\Secure.Txt |
  Format-Table -AutoSize

# 7. Creating the Sales group in AD if it does not exist
$ScriptBlock= {
  try {
    Get-ADGroup -Identity 'Sales' -ErrorAction Stop
  }
  catch {
    New-ADGroup -Name Sales -GroupScope Global |
      Out-Null
  }
}
Invoke-Command -ComputerName DC1 -ScriptBlock $ScriptBlock

# 8. Displaying Sales AD Group
Invoke-Command -ComputerName DC1 -ScriptBlock {
                                   Get-ADGroup -Identity Sales}

# 9. Adding explicit full control for DomainAdmins
$AddAdminHT = @{
  Path         = 'F:\Secure1'
  Account      = 'Reskit\Domain Admins' 
  AccessRights = 'FullControl'
}
Add-NTFSAccess @AddAdminHT

# 10. Removing Builtin\Users access from the Secure.Txt file
$RemoveUsersHT = @{
  Path         = 'F:\Secure1\Secure.Txt'
  Account      = 'Builtin\Users'
  AccessRights = 'FullControl'
}  
Remove-NTFSAccess @RemoveUsersHT

# 11. Removing inherited rights for the folder:
$RemoveInheritRHT = @{
  Path                       = 'F:\Secure1'
  RemoveInheritedAccessRules = $True
}
Disable-NTFSAccessInheritance @RemoveInheritRHT

# 12. Adding Sales group access to the folder
$AddHT = @{
  Path         = 'F:\Secure1\'
  Account      = 'Reskit\Sales' 
  AccessRights = 'FullControl'
}
Add-NTFSAccess @AddHT

# 13. Getting ACL of the Sercure1 folder
Get-NTFSAccess -Path F:\Secure1 |
  Format-Table -AutoSize

# 14. Getting resulting ACL on the Secure.Txt file
Get-NTFSAccess -Path F:\Secure1\Secure.Txt |
  Format-Table -AutoSize
