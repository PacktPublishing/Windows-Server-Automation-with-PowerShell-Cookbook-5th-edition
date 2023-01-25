# 11.1 - Installing Hyper-V inside Windows Server

# Run on HV1

# 1. Installing the Hyper-V feature on HV1, HV2
$InstallSB = {
  Install-WindowsFeature -Name Hyper-V -IncludeManagementTools
}
Invoke-Command -ComputerName HV1, HV2 -ScriptBlock $InstallSB

# 2. Rebooting the servers to complete the installation
Restart-Computer -ComputerName HV2 -Force 
Restart-Computer -ComputerName HV1 -Force 

# 3. Creating a PSSession with both HV Servers (after reboot)
$Sessions = New-PSSession HV1, HV2

# 4. Creating and setting the location for VMs and VHDs on HV1 and HV2
$ConfigSB1 = {
    New-Item -Path C:\VM -ItemType Directory -Force |
        Out-Null
    New-Item -Path C:\VM\VHDS -ItemType Directory -Force |
        Out-Null
    New-Item -Path C:\VM\VMS -ItemType Directory -force |
        Out-Null
}        
Invoke-Command -ScriptBlock $ConfigSB1 -Session $Sessions | 
  Out-Null

# 5. Setting default paths for Hyper-V VM disk/config information
$ConfigSB2 = {
  $VHDS = 'C:\VM\VHDS'
  $VMS  = 'C:\VM\VMS'
  Set-VMHost -ComputerName Localhost -VirtualHardDiskPath $VHDS
  Set-VMHost -ComputerName Localhost -VirtualMachinePath $VMS
}
Invoke-Command -ScriptBlock $ConfigSB2 -Session $Sessions

# 6. Setting NUMA spanning
$ConfigSB3 = {
  Set-VMHost -NumaSpanningEnabled $true
}
Invoke-Command -ScriptBlock $ConfigSB3 -Session $Sessions

# 7. Setting EnhancedSessionMode
$ConfigSB4 = {
 Set-VMHost -EnableEnhancedSessionMode $true
}
Invoke-Command -ScriptBlock $ConfigSB4 -Session $Sessions

# 8. Setting host resource metering on HV1, HV2
$ConfigSB5 = {
 $RMInterval = New-TimeSpan -Hours 0 -Minutes 15
 Set-VMHost -ResourceMeteringSaveInterval $RMInterval
}
Invoke-Command -ScriptBlock $ConfigSB5 -Session $Sessions

# 9. Reviewing key VM host settings
$CheckVMHostSB = {
  Get-VMHost 
}
$Properties = 'Name', 'V*Path','Numasp*', 'Ena*','RES*'
Invoke-Command -Scriptblock $CheckVMHostSB -Session $Sessions |
  Format-Table -Property $Properties