$ErrorActionPreference = "Continue"
$InstallRoot = Join-Path $env:LOCALAPPDATA "DHP-Goose"
$Workspace = Join-Path $HOME "DHP-Goose-Workspace"
$Results = @()

function Add-Check([string]$Name, [bool]$Pass, [string]$Detail) {
    $script:Results += [pscustomobject]@{ Check = $Name; Status = $(if ($Pass) { "PASS" } else { "FAIL" }); Detail = $Detail }
}

$Goose = Get-Command goose -ErrorAction SilentlyContinue
if (-not $Goose) {
    $Candidate = Join-Path $HOME ".local\bin\goose.exe"
    if (Test-Path $Candidate) { $Goose = Get-Item $Candidate }
}
Add-Check "Goose CLI" ($null -ne $Goose) $(if ($Goose) { $Goose.Source ?? $Goose.FullName } else { "not found" })

$Ollama = Get-Command ollama -ErrorAction SilentlyContinue
Add-Check "Ollama" ($null -ne $Ollama) $(if ($Ollama) { (& ollama --version | Out-String).Trim() } else { "not found" })

$ApiReady = $false
try {
    Invoke-RestMethod -Uri "http://localhost:11434/api/tags" -TimeoutSec 2 | Out-Null
    $ApiReady = $true
} catch { }
Add-Check "Ollama API" $ApiReady "http://localhost:11434"

$ModelPresent = $false
if ($Ollama) {
    $ModelPresent = ((& ollama list | Out-String) -match "qwen3:1.7b")
}
Add-Check "Bootstrap model" $ModelPresent "qwen3:1.7b"

Add-Check "DHP runtime" (Test-Path $InstallRoot) $InstallRoot
Add-Check "DHP workspace" (Test-Path $Workspace) $Workspace
Add-Check "UMS" (Test-Path (Join-Path $InstallRoot "ums\UMS.md")) (Join-Path $InstallRoot "ums\UMS.md")
Add-Check "MCP policy" (Test-Path (Join-Path $InstallRoot "mcp\registry.yaml")) (Join-Path $InstallRoot "mcp\registry.yaml")
Add-Check "Employee recipe" (Test-Path (Join-Path $InstallRoot "recipes\dhp-employee.yaml")) (Join-Path $InstallRoot "recipes\dhp-employee.yaml")

$Results | Format-Table -AutoSize
$Failed = @($Results | Where-Object Status -eq "FAIL")
if ($Failed.Count -gt 0) {
    Write-Host ""
    Write-Host "$($Failed.Count) check(s) failed."
    exit 1
}

Write-Host ""
Write-Host "DHP Goose health check: PASS"
exit 0
