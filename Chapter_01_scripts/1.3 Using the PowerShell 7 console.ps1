# 1.3 Using the PowerShell 7 Console
#
# Run on SRV1 after you install PowerShell 7.2
# Run PWSH in elevated console

# 1. Viewing the PowerShell version
$PSVersionTable

# 2. Viewing the $Host variable
$Host

# 3. Looking at the PowerShell process (PWSH)
Get-Process -Id $PID |
  Format-Custom -Property MainModule -Depth 1

# 4. Looking at resource usage statistics
Get-Process -Id $PID |
  Format-List CPU,*Memory*

# 5. Updating the PowerShell 7 help files
$Before = Get-Help -Name about_*
Update-Help -Force | Out-Null
$After = Get-Help -Name about_*
$Delta = $After.Count - $Before.Count
"{0} Conceptual Help Files Added" -f $Delta

# 6. Determining available commands
Get-Command |
  Group-Object -Property CommandType

# 7. Examining the Path Variable
$env:path.split(';')