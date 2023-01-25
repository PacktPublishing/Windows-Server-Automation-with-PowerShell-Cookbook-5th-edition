# 6.6 - Adding Users to Active Directory using a CSV File

# Run On DC1

# 1. Creating a CSV file
$CSVData = @'
FirstName,Initials,LastName,UserPrincipalName,Alias,Description,Password
P, D, Rowley, PDR, Peter, Data Team, Christmas42
C, F, Smith, CFS, Claire, Receptionist, Christmas42
Billy, Bob, JoeBob, BBJB, BillyBob, One of the Bobs, Christmas42
Malcolm, D, Duewrong, Malcolm, Malcolm, Mr. Danger, Christmas42
'@
$CSVData | Out-File -FilePath C:\Foo\Users.Csv

# 2. Importing and displaying the CSV
$Users = Import-CSV -Path C:\Foo\Users.Csv | 
  Sort-Object -Property Alias
$Users | Format-Table

# 3. Adding the users using the CSV
$Users | 
  ForEach-Object -Parallel {
    $User = $_ 
    #  Create a hash table of properties to set on created user
    $Prop = @{}
    #  Fill in values
    $Prop.GivenName         = $User.FirstName
    $Prop.Initials          = $User.Initials
    $Prop.Surname           = $User.LastName
    $Prop.UserPrincipalName = $User.UserPrincipalName + "@Reskit.Org"
    $Prop.Displayname       = $User.FirstName.Trim() + " " +
                              $User.LastName.Trim()
    $Prop.Description       = $User.Description
    $Prop.Name              = $User.Alias
    $PW = ConvertTo-SecureString -AsPlainText $User.Password -Force
    $Prop.AccountPassword   = $PW
    $Prop.ChangePasswordAtLogon = $true
    $Prop.Path                  = 'OU=IT,DC=Reskit,DC=ORG'
    $Prop.Enabled               = $true
    #  Now Create the User
    New-ADUser @Prop
    # Finally, Display User Created
    "Created $($Prop.Name)"
}

# 4. Showing all users in AD (Reskit.Org)
Get-ADUser -Filter * -Property Description | 
  Format-Table -Property Name, UserPrincipalName, Description






### Remove the users created in the script

$Users = Import-Csv C:\foo\users.csv
foreach ($User in $Users)
{
  Get-ADUser -Identity $user.alias | Remove-AdUser
}




