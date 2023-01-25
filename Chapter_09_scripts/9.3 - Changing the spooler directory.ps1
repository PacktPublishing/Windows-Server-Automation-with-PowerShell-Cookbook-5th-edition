
ecipe 11.3 - Changing the spooler directory
#
# Run on PSRV - domain joined host in reskit.org domain

# 1. Loading the System.Printing namespace and classes
Add-Type -AssemblyName System.Printing

# 2. Defining the required permissions
$Permissions =
   [System.Printing.PrintSystemDesiredAccess]::AdministrateServer

# 3. Creating a PrintServer object with the required permissions
$NewObjHT = @{
  TypeName     = 'System.Printing.PrintServer'
  ArgumentList = $Permissions
}
$PrintServer = New-Object @NewObjHT

# 4. Displaying print server properties
$PrintServer

# 5. Observing the default spool folder
"The default spool folder is: [{0}]" -f $PringServer.DefaultSpoolDirectory

# 6. Creating a new spool folder
$NewItemHT = @{
  Path        = 'C:\SpoolPath'
  ItemType    = 'Directory'
  Force       = $true
  ErrorAction = 'SilentlyContinue'
}
New-Item @NewItemHT | Out-Null 

# 7. Updating the default spool folder path
$NewPath = 'C:\SpoolPath'
$PrintServer.DefaultSpoolDirectory = $NewPath

# 8. Committing the change
$PrintServer.Commit()

# 9. Restarting the Spooler to accept the new folder
Restart-Service -Name Spooler

# 10. Verifying the new spooler folder
New-Object -TypeName System.Printing.PrintServer |
  Format-Table -Property Name,
                DefaultSpoolDirectory

#  Another way to set the Spooler directory is by directly editing the registry as follows:

# 11. Stopping the Spooler service
Stop-Service -Name Spooler

# 12. Creating a new spool directory
$SpoolFolder2 = 'C:\SpoolViaRegistry'
$NewItemHT2 = @{
  Path        = $SpoolFolder2
  Itemtype    = 'Directory'
  ErrorAction = 'SilentlyContinue'
}
New-Item  @NewItemHT2 | Out-Null

# 13. Creating the spooler folder and configuring it in the registry
$RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\' +
                'Print\Printers'
$ItemPropHT = @{
  Path    = $RegistryPath
  Name    = 'DefaultSpoolDirectory'
  Value   = $SPL
}
Set-ItemProperty @ItemPropHT

# 14. Restartiing the spooler service
Start-Service -Name Spooler

# 15. Viewing the results
New-Object -TypeName System.Printing.PrintServer |
  Format-Table -Property Name, DefaultSpoolDirectory