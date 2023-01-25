# Recipe 6.3 -  Configuring the Windows Update client Via GPO
#
# Run on srv1

# 1. Ensuring the GP management tools are available on SRV1
Install-WindowsFeature -Name GPMC -IncludeManagementTools | Out-Null

# 2. Creating a new policy and linking it to the domain
$PolicyName = 'Reskit WSUS Policy'
New-GPO -Name $PolicyName
New-GPLink -Name $PolicyName -Target 'dc=reskit,dc=org' 

# 3. Configuring SRV1 to Use WSUS for updates
$WSUSKEY = 'HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU'
$RVHT1 = @{
  Name       = $PolicyName 
  Key        = $WSUSKEY
  ValueName  = 'UseWUServer'
  Type       = 'DWORD'
  Value      = 1
} 
Set-GPRegistryValue @RVHT1 | Out-Null

# 4. Setting AU options
$KEY2 = 'HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU'
$RVHT2 = @{
  Name      = $PolicyName
  Key       = $KEY2
  ValueName = 'AUOptions'
  Type      = 'DWORD'
  Value     = 2
}
Set-GPRegistryValue  @RVHT2 | Out-Null

# 5. Setting the WSUS Server URL
$Session = New-PSSession -ComputerName WSUS1
$WSUSServer = Invoke-Command -Session $Session -ScriptBlock {
  Get-WSUSServer
}
$FS =  "http{2}://{0}:{1}"
$N  = $WSUSServer.Name
$P  = 8530 # default WSUS port
$WSUSURL = $FS -f $n, $p, ('','s')[$WSUSServer.UseSecureConnection]
$KEY3 = 'HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate'
$RVHT3 = @{
Name      = $PolicyName
Key       = $KEY3
ValueName = 'WUServer'
Type      = 'String'
Value     = $WSUSURL
}
Set-GPRegistryValue @RVHT3  | Out-Null                   

# 6. Setting the WU Status server URL                    
$KEY4 = 'HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate'
$RVHT4 = @{
Name       = $PolicyName
Key        = $KEY4
ValueName  = 'WUStatusServer'
Type       = 'String' 
Value      = $WSUSURL
}
Set-GPRegistryValue @RVHT4 | Out-Null      


# 7. Viewing a report on the GPO
$RHT = @{
Name       = $PolicyName
ReportType = 'Html'
Path       = 'C:\foo\out.html'
}
Get-GPOReport @RHT
Invoke-Item -Path $RHT.Path
