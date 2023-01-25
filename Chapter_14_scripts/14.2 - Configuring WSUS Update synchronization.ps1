# Recipe 14.1 - Configuring WUS update synchronization

# Run on SRV1

# 1. Creating a remote session on WSUS1
$Session = New-PSSession -ComputerName WSUS1

# 2. Locating versions of Windows Server supported by Windows Update
Invoke-Command -Session $Session -ScriptBlock {
  Get-WsusProduc
    Where-Object -FilterScript {$_.product.title -match 
                                '^Windows Server'} |
      Select-Object -ExpandProperty Product  |
        Format-Table Title, UpdateSource
}


# 3. Discovering updates for for Windows 11
Invoke-Command -Session $Session -ScriptBlock {
  Get-WsusProduct -TitleIncludes 'Windows 11' |
    Select-Object -ExpandProperty Product |
      Format-Table -Property Title
}


# 4. Create and view a list of software product titles to include

  $Products = 
   (Get-WsusProduct |  
     Where-Object -FilterScript {$_.product.title -match 
                                 '^Windows Server'}).Product.Title
  $Products += @('Microsoft SQL Server 2016','Windows 11')
  $Products


# 5. Assigning the desired products to include in Windows Update
Invoke-Command -Session $Session -ScriptBlock {
  Get-WsusProduct |
    Where-Object {$PSItem.Product.Title -in $Products} |
        Set-WsusProduct
}

# 6. Getting WSUS classification
Invoke-Command -Session $Session -ScriptBlock {
  Get-WsusClassification |
    Select-Object -ExpandProperty Classification |
      Format-Table -Property Title, Description  -Wrap
}

# 7. Building a list of desired update classifications
Invoke-Command -Session $Session -ScriptBlock {
  $UpdateList = @('Critical Updates',
                  'Definition Updates',
                  'Security Updates',
                  'Service Packs',
                  'Update Rollups',
                  'Updates')
}

# 8. Setting the list of desired update classifications in WSUS:
Invoke-Command -Session $Session -ScriptBlock {
  Get-WsusClassification | 
    Where-Object {$_.Classification.Title -in $UpdateList} |
      Set-WsusClassification
}

# 9. Getting Synchronization details
Invoke-Command -Session $Session -ScriptBlock {
  $WSUSServer = Get-WsusServer
  $WSUSSubscription = $WSUSServer.GetSubscription()
}

# 10. Starting synchronizing available updates
Invoke-Command -Session $Session -ScriptBlock {
  $WSUSSubscription.StartSynchronization()
}

# 11. Looping and waiting for syncronization to complete
Invoke-Command -Session $Session -ScriptBlock {
  $IntervalSeconds = 15
  $NP = 'NotProcessing'
  Do {
    $WSUSSubscription.GetSynchronizationProgress()
    Start-Sleep -Seconds $IntervalSeconds
    } While ($WSUSSubscription.GetSynchronizationStatus() -eq $NP) 
}

# 12. Synchronizing the updates which can take a long while to complete.
Invoke-Command -Session $Session -ScriptBlock {
  $IntervalSeconds = 15
  $NP = 'NotProessing'
  #   Wait for synchronizing to start
  Do {
  Write-Output $WSUSSubscription.GetSynchronizationProgress()
  Start-Sleep -Seconds $IntervalSeconds
  }
  While ($WSUSSubscription.GetSynchronizationStatus() -eq $NP)
  #    Wait for all phases of process to end
  Do {
  Write-Output $WSUSSubscription.GetSynchronizationProgress()
  Start-Sleep -Seconds $IntervalSeconds
  } Until ($WSUSSubscription.GetSynchronizationStatus() -eq $NP)
}

# 13. Checking the results of the synchronization
Invoke-Command -Session $Session -ScriptBlock {
  $WSUSSubscription.GetLastSynchronizationInfo()
}

# 14. Configure automatic synchronization to run once per day:
Invoke-Command -Session $Session -ScriptBlock {
  $WSUSSubscription = $WSUSServer.GetSubscription()
  $WSUSSubscription.SynchronizeAutomatically = $true
  $WSUSSubscription.NumberOfSynchronizationsPerDay = 1
  $WSUSSubscription.Save()
}  
