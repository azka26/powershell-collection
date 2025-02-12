. ./manual-build-vue.ps1
. ./manual-build-netcore.ps1

$sourceDir = Get-Location
$outputDir = [IO.Path]::Combine($sourceDir, "output-build")

Remove-Item -Force -Recurse $outputDir -ErrorAction SilentlyContinue

Build-Backend -sourceDir $sourceDir -outputDir $outputDir
Build-Frontend-Vue -sourceDir $sourceDir -outputDir $outputDir -name "dev"

Set-Location $sourceDir
Write-Output "PROCESS COMPLETED"