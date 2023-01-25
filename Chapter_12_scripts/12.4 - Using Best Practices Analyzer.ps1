# 12.4 - Using Best Practices Analyzer

# Run on SRV1 with DC1 and DC2 online

# 1. Creating a remoting session to Windows PowerShell on DC1
$BPASession = New-PSSession -ComputerName DC1

# 2. Discovering the BPA module on DC1
$ScriptBlock1 = {
  Get-Module -Name BestPractices -List |
    Format-Table -AutoSize     
}
Invoke-Command -Session $BPASession -ScriptBlock $ScriptBlock1

# 3. Discovering the commands in the BPA module
$ScriptBlock2 = {
    Get-Command -Module BestPractices  |
      Format-Table -AutoSize
}
Invoke-Command -Session $BPASession -ScriptBlock $ScriptBlock2

# 4. Discovering all available BPA models on DC1
$ScriptBlock3 = {
  Get-BPAModel  |
    Format-Table -Property Name, Id, LastScanTime -AutoSize    
}
Invoke-Command -Session $BPASession -ScriptBlock $ScriptBlock3

# 5. Running the BPA DirectoryServices model on DC1
$ScriptBlock4 = {
  Invoke-BpaModel -ModelID Microsoft/Windows/DirectoryServices -Mode ALL |
    Format-Table -AutoSize
}    
Invoke-Command -Session $BPASession -ScriptBlock $ScriptBlock4

# 6. Getting BPA results from DC1
$ScriptBlock5 = {
  Get-BpaResult -ModelID Microsoft/Windows/DirectoryServices  |
    Where-Object Resolution -ne $null|
      Format-List -Property Problem, Resolution
}    
Invoke-Command -Session $BPASession -ScriptBlock $ScriptBlock5
  