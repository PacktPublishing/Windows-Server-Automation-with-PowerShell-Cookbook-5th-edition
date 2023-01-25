# Recipe 10.4- Creating a Image using a Dockerfile
# 
# run on CH1

# 1. Creating folder and setting location to the folder on CH1
$SitePath = 'C:\RKWebContainer'
$NewItemHT = @{
  Path         = $SitePath
  ItemType     = 'Directory'
  ErrorAction  = 'SilentlyContinue'
}
New-Item @NewItemHT | Out-Null
Set-Location -Path $SitePath

# 2. Creating a script to run in the container to create a new site in the Containe
$ScriptBlock = {
# 2.1 Creating folder in the container
$SitePath = 'C:\RKWebContainer'
$NewItemHT2 = @{
  Path         = $SitePath
  ItemType     = 'Directory'
  ErrorAction  = 'SilentlyContinue'
}
New-Item @NewItemHT2 | Out-Null
Set-Location -Path $NewItemHT2.Path
# 2.1 Creating a page for the site
$PAGE = @'
<!DOCTYPE html>
<html> 
<head><title>Main Page for RKWeb.Reskit.Org</title></head>
<body><p><center><b>
Home Page For RKWEB.RESKIT.ORG
</b></p>
Windows Server 2022, Containers, and PowerShell Rock!
</center/</body></html>
'@
$PAGE | OUT-FILE $SitePath\Index.html | Out-Null
#2.2 Creating a new web site in the container that uses Host headers
$WebSiteHT = @{
  PhysicalPath = $SitePath 
  Name         = 'RKWeb'
  HostHeader   = 'RKWeb.Reskit.Org'
}
New-Website @WebSiteHT
} # End of script block
# 2.5 Save script block to file
$ScriptBlock | Out-File $SitePath\Config.ps1

# 3. Creating a new A record for our soon to be containerized site:
Invoke-Command -Computer DC1.Reskit.Org -ScriptBlock {
  $DNSHT = @{
    ZoneName  = 'Reskit.Org'
    Name      = 'RKWeb'
    IpAddress = '10.10.10.221'
  }    
  Add-DnsServerResourceRecordA @DNSHT
}

# 4. Creating Dockerfile
$DockerFile = @"
FROM mcr.microsoft.com/windows/servercore/iis
LABEL Description="RKWEB Container" Vendor="PS Partnership" Version="1.0.0.42"
RUN powershell -Command Add-WindowsFeature Web-Server
RUN powershell -Command GIP
WORKDIR C:\\RKWebContainer
COPY Config.ps1 \Config.ps1
RUN powershell -command ".\Config.ps1"
"@
$DockerFile  | Out-File -FilePath .\Dockerfile -Encoding ascii

# 5. Building the image
docker build -t rkwebc .

# 6. Running the image
docker run -d --name rkwebc -p 80:80 rkwebc

# 7. Navigating to the container
Invoke-WebRequest -UseBasicParsing HTTP://RKweb.Reskit.Org

# 8. Viewing the web page in the browser
Start-Process "http://RKWeb.Reskit.Org"

# 9. Testing network connection
Test-NetConnection -ComputerName localhost -Port 80

# 10. Cleaning up forcibly
docker container rm rkwebc -f
