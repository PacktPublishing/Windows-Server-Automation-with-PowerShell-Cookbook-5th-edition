# Recipe 8.8 - Implementing FSRM Reporting
#
# Run on FS1 after you run Recipe 8.7 to install FSRM

# 1. Creating a new FSRM storage report for large files on C:\ on FS1
$NewReportHT = @{
  Name             = 'Large Files on FS1'
  NameSpace        = 'C:\'
  ReportType       = 'LargeFiles'
  LargeFileMinimum = 10MB 
  Interactive      = $true 
}
New-FsrmStorageReport @NewReportHT

# 2. Getting existing FSRM reports
Get-FsrmStorageReport -Name * | 
  Format-Table -Property Name, NameSpace, 
                         ReportType, ReportFormat

# 3. Viewing Interactive reports available on FS1
$Path = 'C:\StorageReports\Interactive'
Get-ChildItem -Path $Path

# 4. Viewing the report
$Rep = Get-ChildItem -Path $Path\*.html
Invoke-Item -Path $Rep

# 5. Extracting key information from the FSRM XML output
$XMLFile   = Get-ChildItem -Path $Path\*.xml 
$XML       = [XML] (Get-Content -Path $XMLFile)
$Files     = $XML.StorageReport.ReportData.Item
$Files | Where-Object Path -NotMatch '^Windows|^Program|^Users'|
  Format-Table -Property name, path,
    @{ Name ='Sizemb'
       Expression = {(([int]$_.size)/1mb).tostring('N2')}},
       DaysSinceLastAccessed -AutoSize

# 6. Creating a monthly task in task scheduler
$Date = Get-Date '04:20'
$NewTaskHT = @{
  Time    = $Date
  Monthly = 1
}
$Task = New-FsrmScheduledTask @NewTaskHT
$NewReportHT = @{
  Name             = 'Monthly Files by files group report'
  Namespace        = 'C:\'
  Schedule         = $Task 
  ReportType       = 'FilesbyFileGroup'
  FileGroupINclude = 'Text Files'
  LargeFileMinimum = 25MB
}
New-FsrmStorageReport @NewReportHT | Out-Null

# 7. Getting details of the task
Get-ScheduledTask | 
  Where-Object TaskName -Match 'Monthly' |
    Format-Table -AutoSize

# 8. Running the task now
Get-ScheduledTask -TaskName '*Monthly*' | 
  Start-ScheduledTask
Get-ScheduledTask -TaskName '*Monthly*'

# 9. Viewing the report in the StorageReports folder
$Path   = 'C:\StorageReports\Scheduled'
$Report = Get-ChildItem -Path $Path\*.html
$Report

# 10. Viewing the report
Invoke-item -Path $Report




#  cleanup
Unregister-ScheduledTask -TaskName "StorageReport-Monthly report on Big Files" -Confirm:$False
Get-FsrmStorageReport | Remove-FsrmStorageReport