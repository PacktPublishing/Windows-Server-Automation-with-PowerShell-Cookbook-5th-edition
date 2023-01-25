#  Recipe 144.6 - Managing Updates
#
#  Run on SRV1 after earlier recipes are completed.



# 1. Creating a remoting session to WSUS1
$SessionHT = @{
  ConfigurationName = 'microsoft.powershell'
  ComputerName      = 'WSUS1'
  Name              = 'WSUS'
}
$Session = New-PSSession @SessionHT

# 2. Viewing the status of WSUS1
Invoke-Command -Session $Session -ScriptBlock {
  $WSUSServer = Get-WsusServer
  $WSUSServer.GetStatus()
}

# 3. Viewing computer targets
Invoke-Command -Session $Session -ScriptBlock {
  $WSUSServer.GetComputerTargets() | 
    Sort-Object -Property FullDomainName |
      Format-Table -Property FullDomainName, IPAddress, Last*
}

# 4.  Searching forupdates with titles containing Windows Server 2019
Invoke-Command -Session $Session -ScriptBlock {
  $Title   = 'Windows Server 2022'
  $Updates = 'Security Updates'
  $SecurityUpdates = $WSUSServer.SearchUpdates($Title)
}

# 5 Viewing the matching updates (first 10)
Invoke-Command -Session $Session -ScriptBlock {
  $SecurityUpdates | 
    Sort-Object -Property Title |
      Select-Object -First 10 |
        Format-Table -Property Title, Description
}

# 6. Selecting one of the updates to approve based on the KB article ID
Invoke-Command -Session $Session -ScriptBlock {
  $SelectedUpdate = $SecurityUpdates |
    Where-Object KnowledgebaseArticles -eq 5019080
}


# 7. Defining the computer target group 
Invoke-Command -Session $Session -ScriptBlock {
  $SRVTargetGroup = $WSUSServer.GetComputerTargetGroups() |
    Where-Object -Property Name -eq 'Domain Servers'
}
  
# 8. Approving the update for installation in the target group
Invoke-Command -Session $Session -ScriptBlock {
  $SelectedUpdate.Approve('Install',$SRVTargetGroup)
}

# 9. Selecting one of the updates to decline based on a KB article ID
Invoke-Command -Session $Session -ScriptBlock {
$DeclinedUpdate = $SecurityUpdates |
  Where-Object -Property KnowledgebaseArticles -eq 5019080
}

# 10. Declining the update
Invoke-Command -Session $Session -ScriptBlock {
  $DeclinedUpdate.Decline($DCTargetGroup)
}
