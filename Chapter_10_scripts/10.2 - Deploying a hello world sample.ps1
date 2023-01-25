# Recipe 10.2 - Deploying Ssample containers
#
#  Run on CH1 after installing docker (recipe 10.1)


# 1. Finding hello-world container imagess at the Docker Hub
docker search hello-world

# 2. Pulling the Docker official hello-world image
docker pull hello-world

# 3. Checking the Image just downloaded
docker image ls

# 4. Running the hello-world container image
docker run hello-world

# 5. Getting Server Core image base image
$ServerCore = 'mcr.microsoft.com/windows/servercore:ltsc2022'
docker pull $ServerCore

# 6. Checking the images available now on CH1
docker image ls

# 7. Running the servercore container image
docker run $ServerCore

# 8. Creating a function to get docker image details as objects
Function Get-DockerImage {
  # Getting the images
  $Images = docker image ls |  Select-Object -Skip 1
  # Regex for getting the fields
  $Regex = '^(\S+)\s+(\S+)\s+(\S+)\s+([ \w]+)\s+(\S+)$'
  # Creating an object for each image and emit
  foreach ($Image in $Images) {
  $image -match $Regex  | Out-Null
  $ContainerHT = [ordered] @{
      Name    = $Matches.1
      Tag     = $Matches.2
      ImageId = $Matches.3
      Created = $Matches.4
      Size    = $Matches.5
    } # end hash table
    New-Object -TypeName pscustomobject -Property $ContainerHT
  } # end foreach
  } # end function
  

# 9. Inspecting Server Core Image  
$ServerCoreImage = Get-DockerImage | Where-Object name -match servercore
docker inspect $ServerCoreImage.ImageId | ConvertFrom-Json

# 10. Pulling a Server 2019 container image
$Server2019Image = 'mcr.microsoft.com/windows:1809'
docker pull $Server2019Image 

# 11. Running older server image
docker run $Server2019Image

# 12. Running the image with isolation
docker run --isolation=hyperv $Server2019Image

# 13. Checking difference in run times with Hyper-V
# Running with no isolation
$Start1 = Get-Date
docker run hello-world | Out-Null
$End1 = Get-Date
$Time1 = ($End1-$Start1).TotalMilliseconds
# Running with isolation
$Start2 = Get-Date
docker run --isolation=hyperv hello-world | Out-Null
$End2 = get-date
$Time2 = ($End2-$Start2).TotalMilliseconds
# Displaying the time differences
"Without isolation, took : $Time1 milliseconds"
"With isolation, took    : $Time2 milliseconds"

# 14. Viewing system disk usage
docker system df

# 15. Viewing active containers
docker container ls -a

# 16. Removing active containers
$Actives = docker container ls -q -a
foreach ($Active in $actives) {
  docker container rm $Active -f
}

# 17. Removing all docker images
docker rmi $(docker images -q) -f  | Out-Null

# 18. Removing other docker detritus
docker prune -f

# 19. Checking images and containers
docker image ls
docker container ls 




Function Get-DockerImage {
# Getting the images
$Images = docker image ls |  Select -skip 1      # get rid of the header line
# Regex for getting the fields
$Regex = '^(\S+)\s+(\S+)\s+(\S+)\s+([ \w]+)\s+(\S+)$'
# Creating an object for each image and emit
foreach ($Image in $Images) {
$image -match $Regex  | Out-Null
$ContainerHT = [ordered] @{
    Name    = $Matches.1
    Tag     = $Matches.2
    ImageId = $Matches.3
    Created = $Matches.4
    Size    = $Matches.5
  } # end hash table
  New-Object -TypeName pscustomobject -Property $ContainerHT
} # end foreach
} # end function