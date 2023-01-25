# Recipe 14.1 - Installing Windows Server Update Services
#
# Run as administrator on Srv1


# 1. Creating a remoting session to WSUS1
$SessionHT = @{
  ConfigurationName = 'microsoft.powershell'
  ComputerName      = 'WSUS1'
  Name              = 'WSUS'
}
$Session = New-PSSession @SessionHT

# 2. Installing WSUS on WSUS1
$ScriptBlock1 = {
  $InstallHT = @{
    Name                   = 'UpdateServices' 
    IncludeManagementTools = $true
  }
  Install-WindowsFeature @InstallHT | 
    Format-Table -AutoSize -Wrap
}
Invoke-Command -Session $Session -ScriptBlock $ScriptBlock1

# 3. Determining features installed on WSUS1
Invoke-Command -Session $Session -ScriptBlock {
  Get-WindowsFeature | 
    Where-Object Installed |
      Format-Table
}

# 4. Creating a folder for WSUS update content on WSUS1
$ScriptBlock2 = {
  $WSUSDir = 'C:\WSUS'
  If (-Not (Test-Path -Path $WSUSDir -ErrorAction SilentlyContinue))
      {New-Item -Path $WSUSDir -ItemType Directory | Out-Null}
}
Invoke-Command -Session $Session -ScriptBlock $ScriptBlock2

# 5. Performing post-installation configuration using WsusUtil.exe
$ScriptBlock3 = {
  $WSUSDir = 'C:\WSUS'
  $Child = 'Update Services\Tools\wsusutil.exe'
  $CMD = Join-Path -Path "$env:ProgramFiles\" -ChildPath $Child 
  & $CMD Postinstall CONTENT_DIR="$WSUSDir"
}
Invoke-Command -ComputerName WSUS1 -ScriptBlock $ScriptBlock3

# 6. Viewing the WSUS website on WSUS1
Invoke-Command -ComputerName WSUS1 -ScriptBlock {
  Get-Website -Name ws* | Format-Table -AutoSize
}

# 7. View the cmdlets in the UpdateServices module
Invoke-Command -ComputerName WSUS1 -ScriptBlock {
  Get-Command -Module UpdateServices | 
    Format-Table -AutoSize
}

# 8. Inspecting properties of the object created with Get-WsusServer
Invoke-Command -Session $Session -ScriptBlock {
  $WSUSServer = Get-WsusServer
  $WSUSServer.GetType().Fullname
  $WSUSServer | Select-Object -Property *
}  

# 9. Viewing details of the WSUS Server object
Invoke-Command -Session $Session -ScriptBlock {
  ($WSUSServer | Get-Member -MemberType Method).count
  $WSUSServer | Get-Member -MemberType Method
}

# 10. Viewing WSUS server configuration
Invoke-Command -Session $Session -ScriptBlock {
  $WSUSServer.GetConfiguration() |
    Select-Object -Property SyncFromMicrosoftUpdate,LogFilePath
}

# 11. Viewing product categories after initial install
Invoke-Command -Session $Session -ScriptBlock {
  $WSUSProducts = Get-WsusProduct -UpdateServer $WSUSServer
  "{0} WSUS Products discovered" -f $WSUSProducts.Count
  $WSUSProducts | 
    Select-Object -ExpandProperty Product |
     Format-Table -Property Title,
                             Description
}

# 12. Displaying subscription information
Invoke-Command -Session $Session -ScriptBlock {
  $WSUSSubscription = $WSUSServer.GetSubscription()
  $WSUSSubscription | 
    Select-Object -Property * | 
      Format-List
}

# 13. Getting latest categories of products available from Microsoft Update
Invoke-Command -Session $Session -ScriptBlock {
  $WSUSSubscription.StartSynchronization()
  Do {
    Write-Output $WSUSSubscription.GetSynchronizationProgress()
    Start-Sleep -Seconds 30
  }  
  While ($WSUSSubscription.GetSynchronizationStatus() -ne
                                          'NotProcessing')
}

# 14. Checking the results of the synchronization
Invoke-Command -Session $Session -ScriptBlock {
  $WSUSSubscription.GetLastSynchronizationInfo()
}

# 15.Reviewiong the categories of the products available after synchronzation
Invoke-Command -Session $Session -ScriptBlock {
  $WSUSProducts = Get-WsusProduct -UpdateServer $WSUSServer
  "{0} Product found on WSUS1" -f $WSUSProducts.Count
  $WSUSProducts | 
    Select-Object -ExpandProperty Product -First 25 |
      Format-Table -Property Title,
                              Description
}