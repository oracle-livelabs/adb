#Requires -Version 5.1
# First-run setup for native Windows PowerShell; no WSL or elevation needed.
param([string]$ProjectPath)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Invoke-Checked {
    param([string]$Program, [string[]]$Arguments)
    & $Program @Arguments
    if ($LASTEXITCODE -ne 0) { throw "Command failed: $Program (exit $LASTEXITCODE)." }
}

try {
    if ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) {
        throw 'This script is for Windows. On macOS, use 01-setup-peakgear-mcp.command.'
    }
    Write-Host 'PeakGear LiveLab - Windows setup'
    Write-Host 'Have the ADP_URL from Lab 3 and your reservation Database Password ready.'
    $UvCommand = Get-Command uv -ErrorAction SilentlyContinue
    if (-not $UvCommand) {
        $UvCandidate = Join-Path $env:USERPROFILE '.local\bin\uv.exe'
        if (Test-Path -LiteralPath $UvCandidate) {
            $UvPath = $UvCandidate
        } else {
            Write-Host 'Installing the user-scoped package runner...'
            [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
            $Installer = Join-Path ([IO.Path]::GetTempPath()) ('peakgear-uv-' + [guid]::NewGuid() + '.ps1')
            try {
                Invoke-WebRequest -UseBasicParsing -Uri 'https://astral.sh/uv/install.ps1' -OutFile $Installer
                Invoke-Checked -Program 'powershell.exe' -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $Installer)
            } finally {
                if (Test-Path -LiteralPath $Installer) { Remove-Item -LiteralPath $Installer }
            }
            $UvPath = $UvCandidate
        }
    } else {
        $UvPath = $UvCommand.Source
    }
    if (-not (Test-Path -LiteralPath $UvPath)) { throw 'The package runner was not found after installation. Ask the instructor.' }
    $env:PATH = (Split-Path $UvPath -Parent) + [IO.Path]::PathSeparator + $env:PATH
    Invoke-Checked -Program $UvPath -Arguments @('tool', 'install', '--python', '3.13', '--force', 'oracle-data-studio[mcp]')
    $ToolRoot = (& $UvPath tool dir).Trim()
    if ($LASTEXITCODE -ne 0) { throw 'Could not locate the installed package directory.' }
    $ToolBin = (& $UvPath tool dir --bin).Trim()
    if ($LASTEXITCODE -ne 0) { throw 'Could not locate the installed package commands.' }
    $PythonPath = Join-Path $ToolRoot 'oracle-data-studio\Scripts\python.exe'
    $ConfigCommand = Join-Path $ToolBin 'oracle-data-studio-config.exe'
    if (-not (Test-Path -LiteralPath $PythonPath) -or -not (Test-Path -LiteralPath $ConfigCommand)) {
        throw 'The Data Studio package is incomplete. Ask the instructor.'
    }
    $Helper = Join-Path $PSScriptRoot 'livelab_setup.py'
    foreach ($Name in @('livelab_setup.py', 'livelab_mcp.py', '02-peakgear-livelab-admin.ps1')) {
        if (-not (Test-Path -LiteralPath (Join-Path $PSScriptRoot $Name))) { throw "Starter Kit file missing: $Name. Download the current ZIP." }
    }
    $DatabaseUrl = (Read-Host 'Lab Data Studio URL (ADP_URL from Lab 3)').Trim()
    $DatabaseUrlPattern = '^https://' + '[^/\s]+\.oraclecloudapps\.com/?$'
    if ($DatabaseUrl -notmatch $DatabaseUrlPattern) {
        throw 'Use the HTTPS database-specific ADP_URL, not the browser preview or Data Studio home page.'
    }
    Write-Host 'Paste Database Password from LiveLabs Environment Details when prompted.'
    Write-Host 'Input is hidden and saved in Windows Credential Manager, not in the project.'
    Invoke-Checked -Program $ConfigCommand -Arguments @('set', 'adp', '--url', $DatabaseUrl, '--user', 'PEAKGEAR_USER')
    Invoke-Checked -Program $PythonPath -Arguments @($Helper, 'verify-credentials')
    if (-not $ProjectPath) {
        $DefaultProject = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'peakgear-livelab'
        $ProjectPath = Read-Host "Codex project folder (press Enter for $DefaultProject)"
        if (-not $ProjectPath) { $ProjectPath = $DefaultProject }
    }
    $ProjectPath = [IO.Path]::GetFullPath($ProjectPath)
    New-Item -ItemType Directory -Path $ProjectPath -Force | Out-Null
    $RuntimeDir = Join-Path $env:LOCALAPPDATA 'peakgear-livelab'
    New-Item -ItemType Directory -Path $RuntimeDir -Force | Out-Null
    foreach ($Name in @('livelab_setup.py', 'livelab_mcp.py', '02-peakgear-livelab-admin.ps1')) {
        Copy-Item -LiteralPath (Join-Path $PSScriptRoot $Name) -Destination (Join-Path $RuntimeDir $Name) -Force
    }
    Invoke-Checked -Program $PythonPath -Arguments @($Helper, 'configure', '--project', $ProjectPath, '--runtime', $RuntimeDir, '--python', $PythonPath)
    $Utf8 = New-Object System.Text.UTF8Encoding($false)
    [IO.File]::WriteAllText((Join-Path $RuntimeDir 'starter-path'), $PSScriptRoot, $Utf8)
    [IO.File]::WriteAllText((Join-Path $RuntimeDir 'python-path'), $PythonPath, $Utf8)
    Write-Host 'Success. Open Codex, add/select this local project, and trust it:'
    Write-Host $ProjectPath
    Write-Host 'Create a new task in that project; then paste the Lab 3 boundary once.'
    Write-Host 'Task 2 verifies the active database connection. Setup alone is not a live connection test.'
} catch {
    Write-Error $_ -ErrorAction Continue
    exit 1
}
