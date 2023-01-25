# 4.11 Reporting on Managing AD Replication

# Run on DC1, with DC2, UKDC1 up and running

# 1. Checking replication partners for DC1
Get-ADReplicationPartnerMetadata -Target DC1.Reskit.Org   | 
  Format-List -Property Server, PartnerType, Partner, 
                        Partition, LastRep* 

# 2. Checking AD replication partner metadata in the domain                  
Get-ADReplicationPartnerMetadata -Target Reskit.Org -Scope Domain |
  Format-Table -Property Server, P*Type, Last*

# 3. Investigating group membership metadata
$REPLHT = @{
  Object              = (Get-ADGroup -Identity 'IT Team')
  Attribute           = 'Member'
  ShowAllLinkedValues = $true
  Server              = (Get-ADDomainController)
}
Get-ADReplicationAttributeMetadata @REPLHT |
  Format-Table -Property A*NAME, A*VALUE, *TIME

# 4. Adding two users to the group and removing one
Add-ADGroupMember -Identity 'IT Team' -members Malcolm
Add-ADGroupMember -Identity 'IT Team' -members Claire
Remove-ADGroupMember -Identity 'IT Team' -members Claire -Confirm:$False

# 5. Checking updated metadata
# From DC1 
Get-ADReplicationAttributeMetadata @REPLHT |
  Format-Table -Property A*NAME,A*VALUE, *TIME
# From DC2 
Get-ADReplicationAttributeMetadata -Server DC2 @REPLHT |
  Format-Table -Property A*NAME,A*VALUE, *TIME

# 6. Make a change to a user 
$User = 'Malcolm'
Get-ADUser -Identity $User  | 
  Set-ADUser -Office 'Marin Office'

# 7. Checking updated metadata
$O = Get-ADUser -Identity $User
# From DC1 
Get-ADReplicationAttributeMetadata -Object $O -Server DC1 |
  Where-Object AttributeName -match 'Office'
# From DC2 
Get-ADReplicationAttributeMetadata -Object $O -Server DC2 |
  Where-Object AttributeName -match 'Office'

# 8. Examine Replication partners for both DC1, UKDC1
Get-ADReplicationConnection |
  Format-List -Property Name,ReplicateFromDirectoryServer 
Get-ADReplicationConnection -Server UKDC1 |
  Format-List -Property Name,ReplicateFromDirectoryServer
  
# 9. Use repadmin to check replication summary
repadmin /replsummary
