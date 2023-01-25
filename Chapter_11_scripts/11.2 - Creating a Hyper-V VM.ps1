# Recipe 11.2 - Creating a Hyper-V VM

# run on HV1 - having downloaded the ISO image from
# https://go.microsoft.com/fwlink/p/?LinkID=2195280&clcid=0x409&culture=en-us&country=US
# Save this to C:\Builds\en-windows_server_z64.iso

# 1. Setting up the VM name and paths for this recipe
$VMName      = 'PSDirect'
$VMLocation  = 'C:\VM\VMS'
$VHDlocation = 'C:\VM\VHDS'
$VhdPath     = "$VHDlocation\PSDirect.Vhdx"
$ISOPath     = 'C:\Builds\en_windows_server_x64.iso'
If ( -not (Test-Path -Path $ISOPath -PathType Leaf)) {
  Throw "Windows Server ISO DOES NOT EXIST" 
}

# 2.  Creating a new VM
New-VM -Name $VMName -Path $VMLocation -MemoryStartupBytes 1GB

# 3. Creating a virtual disk file for the VM
New-VHD -Path $VhdPath -SizeBytes 128GB -Dynamic | Out-Null

# 4. Adding the virtual hard disk to the VM
Add-VMHardDiskDrive -VMName $VMName -Path $VhdPath

# 5. Setting ISO image in the VM's DVD drive
$IsoHT = @{
  VMName           = $VMName
  ControllerNumber = 1
  Path             = $ISOPath
}
Set-VMDvdDrive @IsoHT

# 6. Starting the VM
Start-VM -VMname $VMName 

# 7. Viewing the VM
Get-VM -Name $VMName
