$currentDir = Get-Location
Write-Output "Current directory is: $currentDir"

# Function to check if running as administrator
function Test-Administrator {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

$command = "cd $currentDir; .\serve-iis.ps1";
Write-Output $command;

if (-not (Test-Administrator)) 
{
    Write-Output "Script is not running as administrator. Restarting with elevated privileges..."
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -NoExit -Command cd $currentDir; .\serve-iis.ps1"
    exit
}

powershell.exe -File "$currentDir/iis-handler.ps1"