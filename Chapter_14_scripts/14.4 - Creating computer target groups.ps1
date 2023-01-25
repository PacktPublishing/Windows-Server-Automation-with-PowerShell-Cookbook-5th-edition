#  Recipe 14.4 - Creating computer taget groups
#
# Run this on WSUS1

# 1. Creating a remoting session to WSUS1
$SessionHT = @{
    ConfigurationName = 'microsoft.powershell'
    ComputerName      = 'WSUS1'
    Name              = 'WSUS'
  }
$Session = New-PSSession @SessionHT
  
# 2.  Creating a WSUS computer target group for servers
Invoke-Command -Session $Session -ScriptBlock {
  $WSUSServer = Get-WsusServer  -Name WSUS1 -port 8530
  $WSUSServer.CreateComputerTargetGroup('Domain Servers')
}

# 3. Viewing all computer target groups on WSUS1
Invoke-Command -Session $Session -ScriptBlock {
  $WSUSServer.GetComputerTargetGroups() |
    Format-Table -Property Name
}

# 4. Finding the Servers whose name includes SRV
Invoke-Command -Session $Session -ScriptBlock {
  Get-WsusComputer -NameIncludes SRV |
    Format-Table -Property FullDomainName, OSDescription
}

# 5. Adding SRV1, SRV2 to the Domain Servers Target Group
Invoke-Command -Session $Session -ScriptBlock {
  Get-WsusComputer -NameIncludes SRV |
    Where-Object FullDomainName -match '^SRV' |
      Add-WsusComputer -TargetGroupName 'Domain Servers'
}

# 6. Getting the Domain Servers computer target group
Invoke-Command -Session $Session -ScriptBlock {
  $SRVGroup = $WSUSServer.GetComputerTargetGroups() |
                 Where-Object Name -eq 'Domain Servers'
}

# 7. Finding the computers in the group
Invoke-Command -Session $Session -ScriptBlock {
  Get-WsusComputer |
    Where-Object ComputerTargetGroupIDs -Contains $SRVGroup.id |
      Sort-Object -Property FullDomainName | 
          Format-Table -Property FullDomainName, ClientVersion,
                                 LastSyncTime
}