# 11.12 Creating a Hyper-V Status Report

# Run on HV1

# 1. Creating a basic report object hash table
$ReportHT = [Ordered] @{}

# 2. Adding host details to the report hash table
$HostDetails = Get-CimInstance -ClassName Win32_ComputerSystem
$ReportHT.HostName = $HostDetails.Name
$ReportHT.Maker = $HostDetails.Manufacturer
$ReportHT.Model = $HostDetails.Model

# 3. Adding PowerShell and OS version information
$ReportHT.PSVersion = $PSVersionTable.PSVersion.tostring()
# Add OS information:
$OS = Get-CimInstance -Class Win32_OperatingSystem
$ReportHT.OSEdition    = $OS.Caption
$ReportHT.OSArch       = $OS.OSArchitecture
$ReportHT.OSLang       = $OS.OSLanguage
$ReportHT.LastBootTime = $OS.LastBootUpTime
$Now = Get-Date
$UpdateTime = [float] ("{0:n3}" -f (($Now -$OS.LastBootUpTime).Totaldays))
$ReportHT.UpTimeDays = $UpdateTime

# 4. Adding a count of processors in the host
$ProcessorHT = @{
    ClassName  = 'MSvm_Processor'
    Namespace = 'root/virtualization/v2'
}
$Proc = Get-CimInstance @ProcessorHT
$ReportHT.CPUCount = ($Proc |
  Where-Object elementname -match 'Logical Processor').Count

# 5. Adding the current host CPU usage
$ClassName = 'Win32_PerfFormattedData_PerfOS_Processor'
$CPU = Get-CimInstance  -ClassName $ClassName |
         Where-Object Name -eq '_Total'   | 
           Select-Object -ExpandProperty PercentProcessorTime
$ReportHT.HostCPUUsage = $CPU

# 6. Adding the total host physical memory
$Memory = Get-Ciminstance -Class Win32_ComputerSystem
$HostMemory = [float] ( "{0:n2}" -f ($Memory.TotalPhysicalMemory/1GB))
$ReportHT.HostMemoryGB = $HostMemory

# 7. Adding the memory allocated to VMs
$Sum = 0
Get-VM | Foreach-Object {$sum += $_.MemoryAssigned + $Total}
$Sum = [float] ( "{0:N2}" -f ($Sum/1gb) )
$ReportHT.AllocatedMemoryGB = $Sum

# 8. Creating a report header object
$HostDetails = $ReportHT | Format-Table | Out-String

# 9. Creating two new VMs to populate the VM report
New-VM -Name VM2 | Out-Null
New-VM -Name VM3 | Out-Null

# 10. Getting VM details on the local VM host
$VMs       = Get-VM -Name *
$VMDetails = @()

# 11. Getting VM details for each VM
Foreach ($VM in $VMs) {
  # Create VM Report hash table
    $VMReport = [ordered] @{}
  # Add VM's Name
    $VMReport.VMName    = $VM.VMName
  # Add Status
    $VMReport.Status    = $VM.Status
  # Add Uptime
    $VMReport.Uptime     = $VM.Uptime
  # Add VM CPU
    $VMReport.VMCPUUsage = $VM.CPUUsage
  # Replication Mode/Status
    $VMReport.ReplMode   = $VM.ReplicationMode
    $VMReport.ReplState  = $VM.ReplicationState
  # Creating object from Hash table, adding to array
    $VMR = New-Object -TypeName PSObject -Property $VMReport
    $VMDetails += $VMR
}

# 12. Getting the array of VM objects as a table
$VMReportDetails = 
  $VMDetails |
    Sort-Object -Property VMName |
        Format-Table | 
          Out-String


# 13. Creating final Report          
$Report  = "VM Host Details: `n" +
           $HostDetails  +
           "`nVM Details: `n" +
           $VMReportDetails

# 14. Displaying final report
$Report


# 15. Displying report from real HV server

