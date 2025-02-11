. "./iis-function.ps1"

$appPoolName = "essca-app"

# PHYSICAL PATH
$frontendPhysicalPath = "C:\inetpub\wwwroot\essca\frontend"
$backendPhysicalPath = "C:\inetpub\wwwroot\essca\backend"
# END PHYSICAL PATH

# WEB APP PATH
$frontendPath = "/essca"
$backendPath = "/essca/backend"
# END WEB APP PATH

New-IISAppPool -appPoolName $appPoolName -managedRuntimeVersion ""
Stop-IISAppPool -appPoolName $appPoolName

New-IISWebApp -appPoolName $appPoolName -physicalPath $frontendPhysicalPath -appPath $frontendPath
New-IISWebApp -appPoolName $appPoolName -physicalPath $backendPhysicalPath -appPath $backendPath

Start-IISAppPool -appPoolName $appPoolName

Start-Process "msedge.exe" -ArgumentList "http://localhost/essca"