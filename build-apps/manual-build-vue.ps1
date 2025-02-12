function Build-Frontend-Vue {
    param (
        [string]$sourceDir,
        [string]$outputDir,
        [string]$name
    )

    nvm use 16
    
    Set-Location $sourceDir

    $env:NODE_OPTIONS="--max-old-space-size=4096"

    $frontendDir = [IO.Path]::Combine($sourceDir, "frontend")
    $frontendWebConfigDir = [IO.Path]::Combine($sourceDir, "frontend", "web_config")
    $outputPackages = [IO.Path]::Combine($outputDir, "packages")

    New-Item -ItemType Directory -Path $outputPackages -ErrorAction SilentlyContinue

    # BUILD FRONTEND
    Set-Location $frontendDir
    $sourceEnv = [IO.Path]::Combine($frontendDir, ".env.production.$name")
    $targetEnv = [IO.Path]::Combine($frontendDir, ".env.production")
    $distDir = [IO.Path]::Combine($frontendDir, "dist")

    Copy-Item -Force -Path $sourceEnv -Destination $targetEnv

    npm install
    npm run build

    Set-Location $distDir
    $configFile = [IO.Path]::Combine($distDir, "config.js")
    if (Test-Path $configFile) {
        Remove-Item -Force $configFile
    }

    $filter = [IO.Path]::Combine($distDir, "*")
    $outputZip = [IO.Path]::Combine($outputPackages, "frontend-$name.zip")
    Compress-Archive -Path $filter -CompressionLevel Fastest -DestinationPath $outputZip
}
