$ErrorActionPreference = "Stop"
$InstallRoot = Join-Path $env:LOCALAPPDATA "DHP-Goose"
$Workspace = Join-Path $HOME "DHP-Goose-Workspace"
$RuntimeEnv = Join-Path $InstallRoot "runtime.env"

function Resolve-Goose {
    $command = Get-Command goose -ErrorAction SilentlyContinue
    if ($command) { return $command.Source }
    $candidate = Join-Path $HOME ".local\bin\goose.exe"
    if (Test-Path $candidate) { return $candidate }
    throw "Goose CLI not found. Re-run the DHP Goose installer after installing Goose."
}

function Resolve-Ollama {
    $command = Get-Command ollama -ErrorAction SilentlyContinue
    if ($command) { return $command.Source }
    throw "Ollama not found."
}

if (Test-Path $RuntimeEnv) {
    Get-Content $RuntimeEnv | ForEach-Object {
        if ($_ -match '^([^#=]+)=(.*)$') {
            [Environment]::SetEnvironmentVariable($matches[1], $matches[2], "Process")
        }
    }
}

if (-not $env:GOOSE_PROVIDER) { $env:GOOSE_PROVIDER = "ollama" }
if (-not $env:GOOSE_MODEL) { $env:GOOSE_MODEL = "qwen3:1.7b" }
if (-not $env:OLLAMA_HOST) { $env:OLLAMA_HOST = "http://localhost:11434" }
$env:GOOSE_DISABLE_TELEMETRY = "1"
$env:DHP_GOOSE_POLICY = "absolute-zero"

$GooseExe = Resolve-Goose
$OllamaExe = Resolve-Ollama

$OllamaReady = $false
try {
    Invoke-RestMethod -Uri "$($env:OLLAMA_HOST.TrimEnd('/'))/api/tags" -TimeoutSec 2 | Out-Null
    $OllamaReady = $true
} catch {
    Start-Process -FilePath $OllamaExe -ArgumentList "serve" -WindowStyle Hidden
    for ($i = 0; $i -lt 15; $i++) {
        Start-Sleep -Milliseconds 500
        try {
            Invoke-RestMethod -Uri "$($env:OLLAMA_HOST.TrimEnd('/'))/api/tags" -TimeoutSec 2 | Out-Null
            $OllamaReady = $true
            break
        } catch { }
    }
}

if (-not $OllamaReady) {
    throw "Ollama did not become ready at $env:OLLAMA_HOST."
}

$Models = & $OllamaExe list | Out-String
if ($Models -notmatch [regex]::Escape($env:GOOSE_MODEL)) {
    throw "Model '$env:GOOSE_MODEL' is not installed. Run: ollama pull $env:GOOSE_MODEL"
}

New-Item -ItemType Directory -Force -Path $Workspace | Out-Null
Set-Location $Workspace

$BundledDesktop = Get-ChildItem -Path (Join-Path $InstallRoot "desktop") -Filter "Goose.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
$DesktopCandidates = @()
if ($BundledDesktop) { $DesktopCandidates += $BundledDesktop.FullName }
$DesktopCandidates += @(
    (Join-Path $env:LOCALAPPDATA "Programs\Goose\Goose.exe"),
    (Join-Path $env:LOCALAPPDATA "Goose\Goose.exe"),
    (Join-Path $env:ProgramFiles "Goose\Goose.exe")
)
$DesktopCandidates = @($DesktopCandidates | Where-Object { $_ -and (Test-Path $_) })

if ($DesktopCandidates.Count -gt 0) {
    Write-Host "Starting DHP Goose Desktop..."
    Start-Process -FilePath $DesktopCandidates[0] -ArgumentList "`"$Workspace`""
    exit 0
}

Write-Host "DHP Goose Desktop is not installed; starting the verified CLI runtime."
Write-Host "Provider: $env:GOOSE_PROVIDER | Model: $env:GOOSE_MODEL | Policy: $env:DHP_GOOSE_POLICY"
Write-Host "Workspace: $Workspace"
Write-Host ""
& $GooseExe session
