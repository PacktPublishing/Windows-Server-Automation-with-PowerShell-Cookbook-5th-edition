# 10.7 - Managing Filestore quotas
# 
# Run on FS1, with DC1 online

# 1. Installing FS Resource Manager feature on FS1
Import-Module -Name ServerManager -WarningAction 'SilentlyContinue'
$InstallIHT = @{
  Name                   = 'FS-Resource-Manager' 
  IncludeManagementTools = $True
  WarningAction          = 'SilentlyContinue'
}
Install-WindowsFeature @InstallIHT

# 2. Viewing default FSRM Settings
Get-FsrmSetting


# 3. Setting SMTP settings in FSRM
$SMTPHT = @{
  SmtpServer        = 'SMTP.Reskit.Org'  
  FromEmailAddress  = 'admin@psp.co.uk'
  AdminEmailAddress = 'admin@psp.co.uk'
}
Set-FsrmSetting @SMTPHT

# 4. Sending a test email to check the setup
$TestHT = @{
  ToEmailAddress = 'tfl@psp.co.uk'
  Confirm        = $false
}
Send-FsrmTestEmail  @TestHT

# 5. Creating a new FSRM quota template for a 10MB hard limit
$QuotaHT1 = @{
  Name        = '10 MB Reskit Quota'
  Description = 'Filestore Quota (10mb)'
  Size        = 10MB
}
New-FsrmQuotaTemplate @QuotaHT1

# 6. Viewing available FSRM quota templates
Get-FsrmQuotaTemplate |
  Format-Table -Property Name, Description, Size, SoftLimit
  
# 7. Creating a new folder on which to apply a quota
If (-Not (Test-Path C:\Quota)) {
  New-Item -Path C:\Quota -ItemType Directory  |
    Out-Null
}

# 8. Building an FSRM action
$MailBody = @'
User [Source Io Owner] has exceeded the [Quota Threshold]% quota 
threshold for the quota on [Quota Path] on server [Server].  
The quota limit is [Quota Limit MB] MB, and [Quota Used MB] MB 
currently is in use ([Quota Used Percent]% of limit).
'@
$NewActionHT = @{
  Type      = 'Email'
  MailTo    = 'Doctordns@gmail.Com'
  Subject   = 'FSRM Over limit [Source Io Owner]'
  Body      = $MailBody
}
$Action1 = New-FsrmAction @NewActionHT

# 9. Creating an FSRM threshold 
$Thresh = New-FsrmQuotaThreshold -Percentage 85 -Action $Action1

# 10. Building a quota for the C:\Quota folder
$NewQuotaHT1 = @{
  Path      = 'C:\Quota'
  Template  = '10 MB Reskit Quota'
  Threshold = $Thresh
}
New-FsrmQuota @NewQuotaHT1

# 11. Testing the 85% soft quota limit on C:\Quota
Get-ChildItem -Path C:\Quota -Recurse | 
  Remove-Item -Force     # just in case!
$Text1 = '+'.PadRight(8MB)
# Make a first file - under the soft quota
$Text1 | Out-File -FilePath C:\Quota\Demo1.Txt
$Text2 = '+'.PadRight(.66MB)
# Now create a second file to take the user over the soft quota
$Text2 | Out-File -FilePath C:\Quota\Demo2.Txt

# 12. Testing the hard limit quota
$Text1 | Out-File -FilePath C:\Quota\Demo3.Txt    

# 13. Viewing the contents of the C:\Quota folder
Get-ChildItem -Path C:\Quota 
