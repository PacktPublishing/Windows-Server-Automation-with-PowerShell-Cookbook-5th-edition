# Recipe 2.2 - Installing RSAT Tools on Windows Server
#
# Uses SRV1 as a workgroup host


# 1. Displaying counts of available PowerShell commands
$CommandsBeforeRSAT = Get-Command
$CmdletsBeforeRSAT = $CommandsBeforeRSAT  |
    Where-Object CommandType -eq 'Cmdlet'
$CommandCountBeforeRSAT = $CommandsBeforeRSAT.Count
$CmdletCountBeforeRSAT  = $CmdletsBeforeRSAT.Count
"On Host: [$(hostname)]"
"Commands available before RSAT installed [$CommandCountBeforeRSAT]"
"Cmdlets available before RSAT installed  [$CmdletCountBeforeRSAT]"

# 2. Getting command types returned by Get-Command
$CommandsBeforeRSAT |
  Group-Object -Property CommandType

# 3. Checking the object type details
$CommandsBeforeRSAT |
  Get-Member |
    Select-Object -ExpandProperty TypeName -Unique

# 4. Getting the collection of PowerShell modules and a count of
#    modules before adding the RSAT tools
$ModulesBefore = Get-Module -ListAvailable

# 5. Displaying a count of modules available
#    before adding the RSAT tools
$CountOfModulesBeforeRSAT = $ModulesBefore.Count
"$CountOfModulesBeforeRSAT modules available"

# 6. Getting a count of features actually available on SRV1
Import-Module -Name ServerManager -WarningAction SilentlyContinue
$Features = Get-WindowsFeature 
$FeaturesInstalled = $Features | 
                       Where-Object Installed 
$Rsatfeatures = $Features |
                  Where-Object Name -Match 'RSAT'
$RsatFeaturesInstalled = $Rsatfeatures | 
                  Where-Object Installed 

# 7. Displaying counts of features 
"On Host [$(hostname)]"
"Total features available      [{0}]" -f $Features.Count
"Total features installed      [{0}]" -f $FeaturesInstalled.Count
"Total RSAT features available [{0}]" -f $RsatFeatures.Count
"Total RSAT features installed [{0}]" -f $RsatFeaturesInstalled.Count


# 8. Adding ALL RSAT tools to SRV1
Get-WindowsFeature -Name *RSAT* |
  Install-WindowsFeature

# 9. Getting Details of RSAT tools now installed on SRV1
$FeaturesSRV1        = Get-WindowsFeature
$InstalledOnSRV1     = $FeaturesSRV1 | Where-Object Installed
$RsatInstalledOnSRV1 = $InstalledOnSRV1 | Where-Object Installed |
                         Where-Object Name -Match 'RSAT'

# 10. Displaying counts of commands after installing the RSAT tools
"After Installation of RSAT tools on SRV1"
$INS = 'Features installed on SRV1'
"$($InstalledOnSRV1.Count) $INS"
"$($RsatInstalledOnSRV1.Count) $INS"

# 11. Displaying RSAT tools on SRV1
$Modules = "$env:windir\system32\windowspowerShell\v1.0\modules"
$ServerManagerModules = "$Modules\ServerManager"
Update-FormatData -PrependPath "$ServerManagerModules\*.format.ps1xml"
Get-WindowsFeature |
  Where-Object Name -Match 'RSAT'

# 12. Rebooting SRV1
Restart-Computer -Force

