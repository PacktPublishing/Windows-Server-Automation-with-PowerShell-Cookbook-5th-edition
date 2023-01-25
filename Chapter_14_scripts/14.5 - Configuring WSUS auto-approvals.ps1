# Recipe 14.5 - Configuring WSUS Auto Approvals
#
#  Run on SRV1

# 1. Creating a remoting session to WSUS1
$SessionHT = @{
        ConfigurationName = 'microsoft.powershell'
        ComputerName      = 'WSUS1'
        Name              = 'WSUS'
      }
$Session = New-PSSession @SessionHT

# 2. Creating the auto-approval rule
Invoke-Command -Session $Session -ScriptBlock {
  $WSUSServer = Get-WsusServer
  $ApprovalRule = 
    $WSUSServer.CreateInstallApprovalRule('Critical Updates')
}

# 3. Defining a deadline for the rule
Invoke-Command -Session $Session -ScriptBlock {
  $Type = 'Microsoft.UpdateServices.Administration.' + 
          'AutomaticUpdateApprovalDeadline'
  $RuleDeadLine = New-Object -Typename $Type
  $RuleDeadLine.DayOffset = 3
  $RuleDeadLine.MinutesAfterMidnight = 180
  $ApprovalRule.Deadline = $RuleDeadLine
}  

# 4. Adding update classifications to the rule:
Invoke-Command -Session $Session -ScriptBlock {
  $UpdateClassifications = $ApprovalRule.GetUpdateClassifications()
  $CriticalUpdates = $WSUSServer.GetUpdateClassifications() |
    Where-Object -Property Title -eq 'Critical Updates' 
  $UpdateClassifications.Add($CriticalUpdates) | Out-Null
  $Defs = $WSUSServer.GetUpdateClassifications() |
            Where-Object -Property Title -eq 'Definition Updates'
  $UpdateClassifications.Add($Defs) | Out-Null
  $ApprovalRule.SetUpdateClassifications($UpdateClassifications)
}

# 5. Assigning the rule to a computer target group
Invoke-Command -Session $Session -ScriptBlock {
  $Type = 'Microsoft.UpdateServices.Administration.'+
          'ComputerTargetGroupCollection'
  $TargetGroups = New-Object $Type
  $TargetGroups.Add(($WSUSServer.GetComputerTargetGroups() |
    Where-Object -Property Name -eq 'Domain Servers'))
  $ApprovalRule.SetComputerTargetGroups($TargetGroups) |
    Out-Null
}

# 6. Enabling the rule
Invoke-Command -Session $Session -ScriptBlock {
  $ApprovalRule.Enabled = $true
  $ApprovalRule.Save()
}

# 7. Geting a list of approval rules
Invoke-Command -Session $Session -ScriptBlock{
  $WSUSServer.GetInstallApprovalRules()   |
    Format-Table -Property Name, Enabled, Action
}
