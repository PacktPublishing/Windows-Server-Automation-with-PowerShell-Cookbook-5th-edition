# 13.5 - Using WMI methods

# Run on SRV1

# 1. Reviewing methods of Win32_Share class on SRV1
Get-CimClass -ClassName Win32_Share | 
  Select-Object -ExpandProperty CimClassMethods

# 2. Reviewing properties of Win32_Share class
Get-CimClass -ClassName Win32_Share | 
  Select-Object -ExpandProperty CimClassProperties |
    Format-Table -Property Name, CimType

# 3. Creating a new SMB share using the Create() static method
$NewShareDetails = @{
  Name        = 'TestShare1'
  Path        = 'C:\Foo'
  Description = 'Test Share'
  Type        = [uint32] 0 # disk
}    
$CimShareHT = @{
  ClassName  = 'Win32_Share' 
  MethodName = 'Create' 
  Arguments  = $NewShareDetails
}
Invoke-CimMethod @CimShareHT

# 4. Viewing the new SMB share
Get-SMBShare -Name 'TestShare1'

# 5. Viewing the new SMB share using Get-CimInstance
Get-CimInstance -Class Win32_Share -Filter "Name = 'TestShare1'"

# 6. Removing the share
Get-CimInstance -Class Win32_Share -Filter "Name = 'TestShare1'" |
  Invoke-CimMethod -MethodName Delete








  