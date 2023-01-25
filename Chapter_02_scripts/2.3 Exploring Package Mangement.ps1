# Recipe 2.3 - Exploring Package Management
#
# Run from SRV1

# 1. Reviewing the cmdlets in the PackageManagement module
Get-Command -Module PackageManagement

# 2. Reviewing installed providers with Get-PackageProvider
Get-PackageProvider |
  Format-Table -Property Name,
                         Version,
                         SupportedFileExtensions,
                         FromTrustedSource

# 3. Examining available Package Providers
$PROVIDERS = Find-PackageProvider
$PROVIDERS |
    Select-Object -Property Name,Summary |
      Format-Table -AutoSize -Wrap

# 4. Discovering and counting available packages
$PACKAGES = Find-Package
"Discovered {0:N0} packages" -f $PACKAGES.Count

# 5. Showing the first 5 packages discovered
$PACKAGES |
    Select-Object -First 5 |
      Format-Table -AutoSize -Wrap

# 6. Installing the ChocolateyGet provider
Install-PackageProvider -Name ChocolateyGet -Force |
  Out-Null

# 7. Verifying ChocolateyGet is in the list of installed providers
Import-PackageProvider -Name ChocolateyGet
Get-PackageProvider -ListAvailable |
  Select-Object -Property Name,Version

# 8. Discovering Packages using the ChocolateyGet provider
$CPackages = Find-Package -ProviderName ChocolateyGet -Name *
"$($CPackages.Count) packages available via ChocolateyGet"


