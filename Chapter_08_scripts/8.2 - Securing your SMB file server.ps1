# Recipe 8.2 - Securing your SMB file Server

# Run on FS1

# 1. Adding File Server features to FS1
$FeaturesHT = 'FileAndStorage-Services',
              'File-Services',
              'FS-FileServer',
              'RSAT-File-Services'
Add-WindowsFeature -Name $FeaturesHT

# 2. Viewing the SMB server settings
Get-SmbServerConfiguration

# 3. Turning off SMB1 
$ConfigHT1 = @{
  EnableSMB1Protocol = $false 
  Confirm            = $false
}
Set-SmbServerConfiguration @ConfigHT1

# 4. Turning on SMB signing and encryption
$ConfigHT2 = @{
    RequireSecuritySignature = $true
    EnableSecuritySignature  = $true
    EncryptData              = $true
    Confirm                  = $false
}
Set-SmbServerConfiguration @ConfigHT2

# 5. Turning off default server and workstations shares 
$ConfigHT3 = @{
    AutoShareServer       = $false
    AutoShareWorkstation  = $false
    Confirm               = $false
}
Set-SmbServerConfiguration @ConfigHT3

# 6. Turning off server announcements
$ConfigHT4 = @{
    ServerHidden   = $true
    AnnounceServer = $false
    Confirm        = $false
}
Set-SmbServerConfiguration @ConfigHT4

# 7. Restarting SMB Server service with the new configuration
Restart-Service LanManServer -Force




# For testing
<# undo and set back to defults

Get-SMBShare foo* | Remove-SMBShare -Confirm:$False

Set-SmbServerConfiguration -EnableSMB1Protocol $true `
                           -RequireSecuritySignature $false `
                           -EnableSecuritySignature $false `
                           -EncryptData $False `
                           -AutoShareServer $true `
                           -AutoShareWorkstation $false `
                           -ServerHidden $False `
                           -AnnounceServer $True
Restart-Service lanmanserver
#>
