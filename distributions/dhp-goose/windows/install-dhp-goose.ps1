param(
    [string]$Model = "qwen3:1.7b"
)

$ErrorActionPreference = "Stop"
$DistroRoot = Split-Path $PSScriptRoot -Parent
$InstallRoot = Join-Path $env:LOCALAPPDATA "DHP-Goose"
$Workspace = Join-Path $HOME "DHP-Goose-Workspace"
$Desktop = [Environment]::GetFolderPath("Desktop")
$ShortcutPath = Join-Path $Desktop "DHP Goose.lnk"

function Resolve-Goose {
    $command = Get-Command goose -ErrorAction SilentlyContinue
    if ($command) { return $command.Source }

    $candidate = Join-Path $HOME ".local\bin\goose.exe"
    if (Test-Path $candidate) { return $candidate }

    throw "Goose CLI was not found. Install Goose before running this installer."
}

function Resolve-Ollama {
    $command = Get-Command ollama -ErrorAction SilentlyContinue
    if ($command) { return $command.Source }
    throw "Ollama was not found. Install Ollama before running this installer."
}

$GooseExe = Resolve-Goose
$OllamaExe = Resolve-Ollama

New-Item -ItemType Directory -Force -Path $InstallRoot | Out-Null
New-Item -ItemType Directory -Force -Path $Workspace | Out-Null

Copy-Item -Path (Join-Path $DistroRoot "*") -Destination $InstallRoot -Recurse -Force

$UmsPath = Join-Path $InstallRoot "ums\UMS.md"
$HintsPath = Join-Path $Workspace ".goosehints"
$Hints = @"
DHP GOOSE WORKSPACE

Always apply the orchestration contract in:
$UmsPath

Available DHP skill packs are under:
$(Join-Path $InstallRoot "skills")

Approved tool policy is under:
$(Join-Path $InstallRoot "mcp\registry.yaml")

Before non-trivial work, read UMS.md and only the relevant SKILL.md. Keep paid providers disabled. Verify before reporting completion.
"@
Set-Content -Path $HintsPath -Value $Hints -Encoding UTF8

$env:GOOSE_PROVIDER = "ollama"
$env:GOOSE_MODEL = $Model
$env:OLLAMA_HOST = "http://localhost:11434"
$env:GOOSE_DISABLE_TELEMETRY = "1"
$env:DHP_GOOSE_POLICY = "absolute-zero"

$tags = & $OllamaExe list 2>$null | Out-String
if ($tags -notmatch [regex]::Escape($Model)) {
    Write-Host "Downloading bootstrap model $Model ..."
    & $OllamaExe pull $Model
    if ($LASTEXITCODE -ne 0) { throw "Failed to download Ollama model $Model." }
}

$Launcher = Join-Path $InstallRoot "windows\start-dhp-goose.ps1"
$PowerShell = (Get-Command powershell.exe).Source
$Shell = New-Object -ComObject WScript.Shell
$Shortcut = $Shell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = $PowerShell
$Shortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$Launcher`""
$Shortcut.WorkingDirectory = $Workspace
$Shortcut.IconLocation = "$GooseExe,0"
$Shortcut.Description = "DHP Goose - local-first AI employee"
$Shortcut.Save()

$ConfigPath = Join-Path $InstallRoot "runtime.env"
@"
GOOSE_PROVIDER=ollama
GOOSE_MODEL=$Model
OLLAMA_HOST=http://localhost:11434
GOOSE_DISABLE_TELEMETRY=1
DHP_GOOSE_POLICY=absolute-zero
DHP_GOOSE_WORKSPACE=$Workspace
"@ | Set-Content -Path $ConfigPath -Encoding UTF8

Write-Host ""
Write-Host "DHP Goose installation complete."
Write-Host "Shortcut: $ShortcutPath"
Write-Host "Workspace: $Workspace"
Write-Host "Runtime: $InstallRoot"
Write-Host "Provider: ollama"
Write-Host "Model: $Model"
Write-Host "Paid providers: disabled by policy"
Write-Host ""
Write-Host "Double-click 'DHP Goose' on the Desktop to start."
