# 8.9 - Managing Filestore Screening
# 
# Run on FS1 with FSRM loaded

# 1. Examining the existing FSRM file groups
Get-FsrmFileGroup |
  Format-Table -Property Name, IncludePattern

# 2. Examining the existing file screening templates
Get-FsrmFileScreenTemplate |
  Format-Table -Property Name, IncludeGroup, Active

# 3. Creating a new folder
$Path = 'C:\FileScreen'
If (-Not (Test-Path $Path)) {
  New-Item -Path $Path -ItemType Directory  |
    Out-Null
}

# 4. Creating a new file screen
$FileScreenHT =  @{
  Path         = $Path
  Description  = 'Block Executable Files'
  IncludeGroup = 'Executable Files'
}
New-FsrmFileScreen @FileScreenHT

# 5. Testing file screen by copying notepad.exe
$FSTestHT = @{
  Path        = "$Env:windir\notepad.exe"
  Destination = 'C:\FileScreen\notepad.exe'
}
Copy-Item  @FSTestHT

# 6. Setting up an active email notification
$MailBody = 
"[Source Io Owner] attempted to save an executable program to 
[File Screen Path].

This is not allowed!
"
$FSAction = @{
  Type             = 'Email'
  MailTo           = 'DoctorDNS@Gmail.Com' 
  Subject          = 'Warning: attempted to save an executable file'
  Body             = $MailBody
  RunLimitInterval = 60
}
$Notification = New-FsrmAction @FSAction 
$NewFileScreenHT = @{
  Path         = $Path
  Notification = $Notification
  IncludeGroup = 'Executable Files'
  Description  = 'Block any executable file'
  Active       = $true
}
Set-FsrmFileScreen @NewFileScreenHT

# 7. Getting FSRM Notification Limits
Get-FsrmSetting | 
  Format-List -Property "*NotificationLimit"

# 8. Changing FSRM notification limits  
$FSNotificationHT = @{
  CommandNotificationLimit = 1
  EmailNotificationLimit   = 1
  EventNotificationLimit   = 1
  ReportNotificationLimit  = 1
}
Set-FsrmSetting @FSNotificationHT


# 9. 9.	Re-testing the file screen and viewing the FSRM email
Copy-Item @FSTestHT



# for testing
Get-ADGroupMember -Identity 'Enterprise admins'
Add-ADGroupMember -Identity 'Enterprise Admins' -Members jerryg
Get-ADGroupMember -identity 'Enterprise admins' | Format-table -Property name
$SB = {
  $FSTHT = @{
    Path        = "$Env:windir\notepad.exe"
    Destination = '\\SRV1\screen\notepad.txt'
  }
  Copy-Item  @FSTHT
}
Invoke-command -ComputerName SRV1 -ScriptBlock $SB -Credential $Cred



new-smbshare -name screen -path C:\FileScreen


