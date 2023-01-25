# Recipe 8.3 - Creating and securing SMB shares
#
# Run from FS1

# 1. Discovering existing shares and access rights
Get-SmbShare -Name * | 
  Get-SmbShareAccess |
    Format-Table -GroupBy Name

# 2. Creating and sharing a new folder 
New-Item -Path F: -Name ITShare -ItemType Directory |
  Out-Null
New-SmbShare -Name ITShare -Path F:\ITShare

# 3. Updating the share to have a description
$NoCnfHT = @{Confirm=$False}
Set-SmbShare -Name ITShare -Description 'File Share for IT' @NoCnfHT

# 4. Setting folder enumeration mode
$FldrEnumHT = @{
  Nam                   = 'ITShare'
  FolderEnumerationMode = 'AccessBased'
  Force                 = $True
}
Set-SMBShare @FldrEnumHT 

# 5. Setting encryption on for ITShare share
Set-SmbShare -Name ITShare -EncryptData $true -Force

# 6. Removing all access to ITShare share for the Everyone group
$AdminHT1 = @{
  Name        =  'ITShare'
  AccountName = 'Everyone'
  Confirm     =  $false
}
Revoke-SmbShareAccess @AdminHT1

# 7. Adding Reskit\Administrators to have read permission
$AdminHT2 = @{
  Name         = 'ITShare'
  AccessRight  = 'Read'
  AccountName  = 'Reskit\ADMINISTRATOR'
  ConFirm      =  $false 
} 
Grant-SmbShareAccess @AdminHT2

# 8. Adding system full access
$AdminHT3 = @{
    Name          = 'ITShare'
    AccessRight   = 'Full'
    AccountName   = 'NT Authority\SYSTEM'
    Confirm       = $False 
}
Grant-SmbShareAccess  @AdminHT3 | Out-Null

# 9. Setting Creator/Owner to Full Access
$AdminHT4 = @{
    Name         = 'ITShare'
    AccessRight  = 'Full'
    AccountName  = 'CREATOR OWNER'
    Confirm      = $False 
}
Grant-SmbShareAccess @AdminHT4  | Out-Null

# 10. Granting Sales group read access, SalesAdmins has Full access
$AdminHT5 = @{
    Name        = 'ITShare'
    AccessRight = 'Read'
    AccountName = 'Sales'
    Confirm     = $false 
}
Grant-SmbShareAccess @AdminHT5 | Out-Null

# 11. Reviewing share access
Get-SmbShareAccess -Name ITShare | 
  Sort-Object AccessRight

# 12. Set file ACL to be same as share acl
Set-SmbPathAcl -ShareName 'ITShare'

# 13. Creating a file in F:\ITShare
'File Contents' | Out-File -FilePath F:\ITShare\File.Txt

# 14. Setting file ACL to be same as share ACL
Set-SmbPathAcl -ShareName 'ITShare'

# 15. Viewing file ACL
Get-NTFSAccess -Path F:\ITShare\File.Txt |
  Format-Table -AutoSize
  




# For testing

<# reset the shares 
Get-smbshare ITShare| Remove-SmbShare -Confirm:$false

#>
