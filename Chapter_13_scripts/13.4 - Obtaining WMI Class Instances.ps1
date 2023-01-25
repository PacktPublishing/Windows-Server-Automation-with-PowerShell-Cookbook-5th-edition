# 13.4 - Obtaining WMI Class Instances
# 
# run on SRV1

# 1. Using Get-CimInstance in the default namespace
Get-CimInstance -ClassName Win32_Share

# 2. Getting WMI objects from a non-default namespace
$Instance1 = @{
  Namespace = 'ROOT\directory\LDAP'
  ClassName = 'ds_group'
}
Get-CimInstance @Instance1 |
  Sort-Object -Property Name |
    Select-Object -First 10 |
      Format-Table -Property DS_name, DS_distinguishedName

# 3. Using a WMI filter
$Filter = "ds_Name LIKE '%operator%' "
Get-CimInstance @Instance1  -Filter $Filter |
  Format-Table -Property DS_Name

# 4. Using a WMI query
$Query = @"
  SELECT * from ds_group
    WHERE ds_Name like '%operator%'
"@
Get-CimInstance -Query $Query -Namespace 'root\directory\LDAP' |
  Format-Table DS_Name

# 5. Getting a WMI object from a remote system (DC1)
Get-CimInstance -CimSession DC1 -ClassName Win32_ComputerSystem | 
  Format-Table -AutoSize


