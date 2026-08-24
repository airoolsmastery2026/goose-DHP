$ErrorActionPreference = "Stop"
$DistroRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent

$RequiredFiles = @(
    "README.md",
    "init-config.yaml",
    "ums\UMS.md",
    "mcp\registry.yaml",
    "recipes\dhp-employee.yaml",
    "skills\engineering\SKILL.md",
    "skills\research\SKILL.md",
    "skills\dhp-business\SKILL.md",
    "skills\dhp-digital-studio\SKILL.md",
    "windows\install-dhp-goose.ps1",
    "windows\start-dhp-goose.ps1",
    "windows\healthcheck.ps1"
)

$Failures = @()
foreach ($RelativePath in $RequiredFiles) {
    $Path = Join-Path $DistroRoot $RelativePath
    if (-not (Test-Path $Path)) {
        $Failures += "Missing required file: $RelativePath"
    }
}

$PowerShellFiles = Get-ChildItem -Path (Join-Path $DistroRoot "windows") -Filter "*.ps1" -File
foreach ($File in $PowerShellFiles) {
    $Tokens = $null
    $Errors = $null
    [System.Management.Automation.Language.Parser]::ParseFile($File.FullName, [ref]$Tokens, [ref]$Errors) | Out-Null
    if ($Errors.Count -gt 0) {
        foreach ($ParseError in $Errors) {
            $Failures += "PowerShell parse error in $($File.Name): $($ParseError.Message)"
        }
    }
}

$Config = Get-Content (Join-Path $DistroRoot "init-config.yaml") -Raw
foreach ($Expected in @("active_provider: ollama", "memory:", "skills:", "todo:", "summon:", "GOOSE_MODE: smart_approve")) {
    if ($Config -notmatch [regex]::Escape($Expected)) {
        $Failures += "init-config.yaml missing: $Expected"
    }
}

$Recipe = Get-Content (Join-Path $DistroRoot "recipes\dhp-employee.yaml") -Raw
foreach ($Expected in @("version: 1.0.0", "instructions:", "extensions:", "name: developer", "name: memory", "name: skills", "name: todo", "name: summon", "prompt:")) {
    if ($Recipe -notmatch [regex]::Escape($Expected)) {
        $Failures += "dhp-employee.yaml missing: $Expected"
    }
}

$Ums = Get-Content (Join-Path $DistroRoot "ums\UMS.md") -Raw
foreach ($Expected in @("Never report completion", "Select only the minimum relevant set", "Prefer local and zero-cost", "Verify")) {
    if ($Ums -notmatch [regex]::Escape($Expected)) {
        $Failures += "UMS contract missing gate: $Expected"
    }
}

$Launcher = Get-Content (Join-Path $DistroRoot "windows\start-dhp-goose.ps1") -Raw
foreach ($Expected in @("GOOSE_ADDITIONAL_CONFIG_FILES", "DHP_GOOSE_POLICY", "ollama", "--with-builtin")) {
    if ($Launcher -notmatch [regex]::Escape($Expected)) {
        $Failures += "Launcher missing runtime gate: $Expected"
    }
}

if ($Failures.Count -gt 0) {
    $Failures | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Host "DHP Goose distribution validation: PASS"
Write-Host "Validated $($RequiredFiles.Count) required files and $($PowerShellFiles.Count) PowerShell scripts."
exit 0
