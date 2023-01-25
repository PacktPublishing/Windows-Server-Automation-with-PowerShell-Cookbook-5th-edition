# Recipe 10.3 - Deploying IIS in a container
#
# Run from CH1
# Run inside the console, not ISE or VSCode

# 1.  Creating the reskitapp folder
$EA = @{ErrorAction='SilentlyContinue'}
New-Item -Path C:\ReskitApp -ItemType Directory @EA

#  2. Creating a web page
$FileName = 'C:\Reskitapp\Index.htm'
$Index = @"
<!DOCTYPE html>
<html><head><title>
ReskitApp Container Application</title></head>
<body><p><center><b>
HOME PAGE FOR RESKITAPP APPLICATION</b></p>
Running in a container in Windows Server 2022<p>
</center><br><hr></body></html>
"@
$Index | Out-File -FilePath $FileName

# 3. Getting a server core with IIS image from the Docker registry:
$Image = 'mcr.microsoft.com/windows/servercore/iis'
docker pull $Image

# 4. Running the image as a container named rkwebc
docker run -d -p80:80 --name rkwebc "$Image"

#  5. Copying the page into the container
Set-Location -Path C:\Reskitapp
docker cp .\index.htm rkwebc:c:\inetpub\wwwroot\index.htm

# 6. Viewing the page
Start-Process "Http://CH1.Reskit.Org/Index.htm"

# 7. Cleaning up
docker rm rkwebc -f | Out-Null
docker image rm  mcr.microsoft.com/windows/servercore/iis | 
  Out-Null