# Recipe 9.4 -  Changing Printer Drivers
#
# Run on Psrv - domain joined host in reskit.org domain
# Run the other recipes to create the printer.

# 1. Adding the print driver for the new printing device
$Model2 = 'Xerox WorkCentre 6515 PCL6'
Add-PrinterDriver -Name $Model2

# 2. Viewing loaded printer drivers:
Get-PrinterDriver

# 3. Getting the Sales group printer object and store it in $Printer
$PrinterName = 'SalesPrinter1'
$Printer  = Get-Printer -Name $PrinterName

# 4. Updating the driver using the Set-Printer cmdlet
$Printer | Set-Printer -DriverName $Model2

# 5. Observing the updated printer driver
Get-Printer -Name $PrinterName | 
  Format-Table -Property Name, DriverName, PortName, 
                Published, Shared