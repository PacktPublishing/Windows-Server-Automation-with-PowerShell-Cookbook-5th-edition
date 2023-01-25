# 15.7 - Implementing Permanent WMI Event Handling

# Run on DC1

# 1. Creating a list of valid users for the Enterprise Admins group
$OKUsersFile = 'C:\Foo\OKUsers.Txt'
$OKUsers  =  @'
Administrator
JerryG
'@
$OKUsers | 
  Out-File -FilePath $OKUsersFile

# 2. Defining helper functions to get/remove permanent events
Function Get-WMIPE {
  '*** Event Filters Defined ***'
  $NS = 'ROOT\subscription'
  $CLass1 = '__EventFilter'
  Get-CimInstance -Namespace $NS -ClassName $CLass1 |
    Where-Object Name -eq "EventFilter1" |
     Format-Table Name, Query
  '***Consumer Defined ***'
  $Class2 = 'CommandLineEventConsumer'
  Get-CimInstance -Namespace $NS -Classname  $Class2 |
    Where-Object {$_.Name -eq "EventConsumer1"}  |
     Format-Table Name, Commandlinetemplate
  '***Bindings Defined ***'
  $Class3 = '__FilterToConsumerBinding'
  Get-CimInstance -Namespace root\subscription -ClassName $Class3 |
    Where-Object -FilterScript {$_.Filter.Name -eq "EventFilter1"} |
      Format-Table Filter, Consumer
}
Function Remove-WMIPE {
  $NS     = 'Root\Subscription'
  $Class1 = '__EventFilter'
  $Class2 = 'CommandLineEventConsumer'
  $Class3 = '__FilterToConsumerBinding'
  Get-CimInstance -Namespace $NS -Classname $class1  | 
    Where-Object Name -eq "EventFilter1" |
      Remove-CimInstance
  Get-CimInstance -Namespace $NS -ClassName $Class2 | 
    Where-Object Name -eq 'EventConsumer1' |
      Remove-CimInstance
  Get-CimInstance -Namespace $NS -ClassName $Class3 |
    Where-Object -FilterScript {$_.Filter.Name -eq 'EventFilter1'}   |
      Remove-CimInstance
}

# 3. Creating an event filter query
$Group = 'Enterprise Admins'
$Query = @"
  SELECT * From __InstanceModificationEvent Within 10  
   WHERE TargetInstance ISA 'ds_group' AND 
         TargetInstance.ds_name = '$Group'
"@

# 4. Creating the event filter
$Param = @{
  QueryLanguage =  'WQL'
  Query          =  $Query
  Name           =  "EventFilter1"
  EventNameSpace =  "root/directory/LDAP"
}
$IHT = @{
  ClassName = '__EventFilter'
  Namespace = 'root/subscription'
  Property  = $Param
}        
$InstanceFilter = New-CimInstance @IHT

# 5. Creating the Monitor.ps1 script run when the WMI event occurs
$Monitor = @'
$LogFile   = 'C:\Foo\Grouplog.Txt'
$Group     = 'Enterprise Admins'
"On:  [$(Get-Date)]  Group [$Group] was changed" | 
  Out-File -Force $LogFile -Append -Encoding Ascii
$ADGM = Get-ADGroupMember -Identity $Group
# Display who's in the group
"Group Membership"
$ADGM | Format-Table Name, DistinguishedName |
  Out-File -Force $LogFile -Append  -Encoding Ascii
$OKUsers = Get-Content -Path C:\Foo\OKUsers.txt
# Look at who is not authorized
foreach ($User in $ADGM) {
  if ($User.SamAccountName -notin $OKUsers) {
    "Unauthorized user [$($User.SamAccountName)] added to $Group"  | 
      Out-File -Force $LogFile -Append  -Encoding Ascii
  }
}
"**********************************`n`n" | 
Out-File -Force $LogFile -Append -Encoding Ascii
'@
$Monitor | Out-File -Path C:\Foo\Monitor.ps1

# 6. Creating a WMI event consumer
#    The consumer runs PowerShell 7 to execute C:\Foo\Monitor.ps1
$CLT = 'Pwsh.exe -File C:\Foo\Monitor.ps1'
$Param =[ordered] @{
  Name                = 'EventConsumer1'
  CommandLineTemplate = $CLT
}
$ECHT = @{
  Namespace = 'root/subscription'
  ClassName = "CommandLineEventConsumer"
  Property  = $param
}        
$InstanceConsumer = New-CimInstance @ECHT

# 7. Binding the filter and consumer
$Param = @{
  Filter   = [ref]$InstanceFilter     
  Consumer = [ref]$InstanceConsumer
}
$IBHT = @{
  Namespace = 'root/subscription'
  ClassName = '__FilterToConsumerBinding'
  Property  = $Param
}
$InstanceBinding = New-CimInstance   @IBHT

# 8. Viewing the event registration details
Get-WMIPE  

# 9. Adding a user to the Enterprise Admins group
Add-ADGroupMember -Identity 'Enterprise admins' -Members Malcolm

# 10. Viewing Grouplog.txt file
Get-Content -Path C:\Foo\Grouplog.txt

# 11. Tidying up
Remove-WMIPE   # invoke this function you defined above
$RGMHT = @{
 Identity = 'Enterprise admins'
 Member   = 'Malcolm'
 Confirm  = $false
}
Remove-ADGroupMember @RGMHT
Get-WMIPE       # ensure you have removed the event handling


