# Recipe 8.4 - Accessing SMB shares
#
# Run from SRV1 - Uses the ITShare share on FS1 created earlier
# Run in an elevated console

# 1. Examining the SMB client's configuration on SRV1
Get-SmbClientConfiguration

# 2. Setting Signing of SMB packets
$ConfirmHT = @{Confirm=$false}
Set-SmbClientConfiguration -RequireSecuritySignature $True @ConfirmHT

# 3. Examining SMB client's network interface
Get-SmbClientNetworkInterface |
    Format-Table

# 4. Examining the shares provided by FS1
net view \\FS1

# 5. Creating a drive mapping, mapping R: to the share on server FS1
New-SmbMapping -LocalPath R: -RemotePath \\FS1\ITShare

# 6. Viewing the shared folder mapping
Get-SmbMapping

# 7. Viewing the shared folder contents
Get-ChildItem -Path R:

# 8. Viewing existing connections 
Get-SmbConnection
