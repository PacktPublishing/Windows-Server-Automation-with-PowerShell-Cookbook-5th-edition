# 2.1 - Using Windows PowerShell compatibility
# Run on SRV1 with PowerShell/VSCode installed
# Run in VS Code

# 1. Importing the ServerManager module
Import-Module -Name ServerManager

# 2. Viewing module details
Get-Module -Name ServerManager |
  Format-List

# 3. Displaying a Windows Feature
Get-WindowsFeature -Name 'TFTP-Client'

# 4. Running the same command in a remoting session
$Session = Get-PSSession -Name WinPSCompatSession
Invoke-Command -Session $Session -ScriptBlock {
  Get-WindowsFeature -Name 'TFTP-Client' |
    Format-Table
}

# 5. Getting the path to Windows PowerShell modules
$Paths = $env:PSModulePath -split ';'
$S32Path = $Paths |
  Where-Object {$_.ToString() -match 'system32'}
"System32 path: [$S32Path]"

# 6. Displaying path to the format XML for Server Manager module
$FXML = "$S32path/ServerManager"
$FF = Get-ChildItem -Path $FXML\*.format.ps1xml
"Format XML files:"
"     $($FF.Name)"

# 7. Updating format XML in PowerShell 7
Foreach ($F in $FF) {
    Update-FormatData -PrependPath $F.FullName}

# 8. Using the command with improved output
Get-WindowsFeature -Name TFTP-Client