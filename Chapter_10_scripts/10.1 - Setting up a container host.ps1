# Recipe 19.1 - Setting up a container host

# Run on CH1

# 1. Installing the Docker provider module
$InstallHT1 = @{
  Name       = 'DockerMSFTProvider'
  Repository = 'PSGallery'
  Force      = $True
}
Install-Module @InstallHT1

# 2. Installing the latest version of the docker package
$InstallHT2 = @{
  Name         = 'Docker'
  ProviderName = 'DockerMSFTProvider'
  Force        = $True
}
Install-Package @InstallHT2

# 3. Ensuring Hyper-V and related tools are added
Add-WindowsFeature -Name Hyper-V -IncludeManagementTools | 
  Out-Null

# 4. Removing Defender as it interferes with Docker
Remove-WindowsFeature -Name Windows-Defender |
  Out-Null

# 5. Restarting the computer to enable docker and containers
Restart-Computer 

# 6. Checking Windows Containers and Hyper-V features are installed on CH1
Get-WindowsFeature -Name Containers, Hyper-v 

# 7. Checking Docker service
Get-Service -Name Docker   

# 8. Checking Docker Version information
docker version             

# 9. Displaying docker configuration information
docker info
