param(
    [string]$Model = "qwen3:1.7b",
    [switch]$SkipDesktop
)

$ErrorActionPreference = "Stop"
$LocalInstaller = Join-Path $PSScriptRoot "distributions\dhp-goose\windows\install-dhp-goose.ps1"

if (Test-Path $LocalInstaller) {
    & $LocalInstaller -Model $Model -SkipDesktop:$SkipDesktop
    exit $LASTEXITCODE
}

$RepoZip = "https://github.com/airoolsmastery2026/goose-DHP/archive/refs/heads/main.zip"
$TempRoot = Join-Path $env:TEMP ("dhp-goose-setup-" + [guid]::NewGuid().ToString("N"))
$ZipPath = Join-Path $TempRoot "goose-DHP.zip"
$ExtractPath = Join-Path $TempRoot "repo"

New-Item -ItemType Directory -Force -Path $TempRoot | Out-Null
New-Item -ItemType Directory -Force -Path $ExtractPath | Out-Null

try {
    Write-Host "Downloading DHP Goose distribution..."
    Invoke-WebRequest -Uri $RepoZip -OutFile $ZipPath -UseBasicParsing
    Expand-Archive -Path $ZipPath -DestinationPath $ExtractPath -Force

    $Installer = Get-ChildItem -Path $ExtractPath -Filter "install-dhp-goose.ps1" -Recurse | Select-Object -First 1
    if (-not $Installer) {
        throw "DHP Goose installer was not found in the downloaded repository."
    }

    & $Installer.FullName -Model $Model -SkipDesktop:$SkipDesktop
}
finally {
    Remove-Item -Path $TempRoot -Recurse -Force -ErrorAction SilentlyContinue
}
