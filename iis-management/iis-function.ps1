Import-Module WebAdministration

function New-IISAppPool {
    param (
        [string]$appPoolName,
        [string]$managedRuntimeVersion = "v4.0",
        [string]$managedPipelineMode = "Integrated"
    )

    try {
        $state = Get-WebAppPoolState -Name $appPoolName -ErrorAction Ignore
    }
    catch {
        $state = $null
    }

    if ($null -eq $state)
    {
        $newAppPool = New-WebAppPool -Name $appPoolName
        $newAppPool.managedRuntimeVersion = $managedRuntimeVersion
        $newAppPool.managedPipelineMode = $managedPipelineMode
        $newAppPool | Set-Item

        Write-Output "Application pool '$appPoolName' created successfully."
    }
    else
    {
        Write-Output "Application pool '$appPoolName' already exists."
    }
}

function Stop-IISAppPool {
    param (
        [string]$appPoolName
    )

    $state = Get-WebAppPoolState -Name $appPoolName

    if ($state.Value -eq "Started") {
        Write-Output "Stopping application pool '$appPoolName'..."
        Stop-WebAppPool -Name $appPoolName
    }

    while ((Get-WebAppPoolState -Name $appPoolName).Value -ne "Stopped") {
        Start-Sleep -Milliseconds 200
    }
    Write-Output "Application pool '$appPoolName' has stopped."
}

function Start-IISAppPool {
    param (
        [string]$appPoolName
    )

    $state = Get-WebAppPoolState -Name $appPoolName

    if ($state.Value -eq "Stopped") {
        Write-Output "Starting application pool '$appPoolName'..."
        Start-WebAppPool -Name $appPoolName
    }

    while ((Get-WebAppPoolState -Name $appPoolName).Value -ne "Started") {
        Start-Sleep -Milliseconds 200
    }

    Write-Output "Application pool '$appPoolName' has started."
}

function New-IISWebApp {
    param (
        [string]$appPoolName,
        [string]$physicalPath,
        [string]$appPath = "/"
    )

    if (-Not (Test-Path $physicalPath)) {
        New-Item -Path $physicalPath -ItemType Directory
    }

    $site = Get-Website -Name "Default Web Site" -ErrorAction Ignore
    if ($null -eq $site) {
        New-Website -Name "Default Web Site" -Port 80 -PhysicalPath $physicalPath -ApplicationPool $appPoolName
        Write-Output "Website 'Default Web Site' created successfully."
    } else {
        Write-Output "Website 'Default Web Site' already exists."
    }

    $app = Get-WebApplication -Site "Default Web Site" -Name $appPath -ErrorAction Ignore
    if ($null -eq $app) {
        New-WebApplication -Site "Default Web Site" -Name $appPath -PhysicalPath $physicalPath -ApplicationPool $appPoolName
        Write-Output "Web application '$appPath' created successfully under 'Default Web Site'."
    } else {
        Write-Output "Web application '$appPath' already exists under 'Default Web Site'."
    }
}