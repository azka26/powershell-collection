function Build-Backend {
    param (
        [string]$sourceDir,
        [string]$outputDir,
        [string[]]$filesToRemove = @("web.config")
    )

    $backendDir = [IO.Path]::Combine($sourceDir, "backend")
    $hangfireDir = [IO.Path]::Combine($backendDir, "src", "HangfireJobWorker")
    $apiDir = [IO.Path]::Combine($backendDir, "src", "PublicApi")
    $outputPackages = [IO.Path]::Combine($outputDir, "packages")

    $hangfirePublished = [IO.Path]::Combine($outputDir, "hangfire-published")
    $apiPublished = [IO.Path]::Combine($outputDir, "api-published")
    $backendPublished = [IO.Path]::Combine($outputDir, "published")

    Set-Location $sourceDir
    New-Item -ItemType Directory -Path $outputPackages -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Path $backendPublished -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Path $apiPublished -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Path $hangfirePublished -ErrorAction SilentlyContinue

    # BACKEND
    Set-Location $backendDir
    dotnet clean
    dotnet restore --no-cache

    # HANGFIRE
    Set-Location $hangfireDir
    dotnet build -r win-x64 HangfireJobWorker.csproj --no-restore --configuration Release --self-contained false
    dotnet publish -r win-x64 --configuration Release HangfireJobWorker.csproj -o $hangfirePublished --self-contained false
    $filter = [IO.Path]::Combine($hangfirePublished, "*")
    Copy-Item -Path $filter -Destination $backendPublished -Recurse -Force

    # API
    Set-Location $apiDir
    dotnet build -r win-x64 PublicApi.csproj --no-restore --configuration Release --self-contained false
    dotnet publish -r win-x64 --configuration Release PublicApi.csproj -o $apiPublished --self-contained false
    $filter = [IO.Path]::Combine($apiPublished, "*")
    Copy-Item -Path $filter -Destination $backendPublished -Recurse -Force

    # PACKAGE ZIP
    Set-Location $backendPublished

    foreach ($file in $filesToRemove) 
    {
        $fileToRemove = [IO.Path]::Combine($backendPublished, $file)
        if (Test-Path $fileToRemove) {
            Remove-Item -Force $fileToRemove -ErrorAction SilentlyContinue
        }
    }

    $zipFileName = [IO.Path]::Combine($backendPublished, "backend.zip")
    $outputZip = [IO.Path]::Combine($outputPackages, "backend.zip")
    $filter = [IO.Path]::Combine($backendPublished, "*")
    
    if (Test-Path $zipFileName) {
        Remove-Item -Force $zipFileName -ErrorAction SilentlyContinue
    }
    
    Compress-Archive -Path $filter -CompressionLevel Fastest -DestinationPath $outputZip
}

# Example usage:
# Build-Backend -sourceDir "D:\amn\bsi-ams"
