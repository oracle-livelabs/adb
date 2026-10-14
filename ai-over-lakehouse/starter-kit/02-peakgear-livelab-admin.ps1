#Requires -Version 5.1
# Local maintenance only. This is not database ADMIN access or cleanup.
param([ValidateSet('Menu', 'Restart', 'Stop', 'Status', 'Refresh')][string]$Action = 'Menu')

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Get-LiveLabProcesses {
    $Wrapper = Join-Path $RuntimeDir 'livelab_mcp.py'
    $Identity = [Security.Principal.WindowsIdentity]::GetCurrent().Name
    foreach ($Process in Get-CimInstance Win32_Process -Filter "Name = 'python.exe' OR Name = 'pythonw.exe'") {
        if ($Process.CommandLine -and $Process.CommandLine -match [regex]::Escape($Wrapper)) {
            $Owner = Invoke-CimMethod -InputObject $Process -MethodName GetOwner
            if ($Owner.ReturnValue -eq 0 -and ($Owner.Domain + '\' + $Owner.User) -eq $Identity) { $Process }
        }
    }
}

function Stop-LiveLab {
    $Sessions = @(Get-LiveLabProcesses)
    foreach ($Session in $Sessions) {
        # A Windows venv has a launcher and child Python process. One may exit
        # while the other is being stopped; an already-exited PID is success.
        try { Stop-Process -Id $Session.ProcessId -ErrorAction Stop } catch {
            if (Get-Process -Id $Session.ProcessId -ErrorAction SilentlyContinue) { throw }
        }
    }
    Write-Host "PeakGear cleanup complete ($($Sessions.Count) matched process(es)). Other MCP servers and database data are unchanged."
}

function Show-LiveLabStatus {
    Write-Host "Configured project: $ProjectPath"
    Write-Host "PeakGear LiveLab processes: $(@(Get-LiveLabProcesses).Count)"
    Write-Host 'A new Codex task starts the configured stdio server automatically.'
}

function Refresh-LiveLab {
    $StarterPath = [IO.File]::ReadAllText((Join-Path $RuntimeDir 'starter-path')).Trim()
    foreach ($Name in @('livelab_setup.py', 'livelab_mcp.py', '02-peakgear-livelab-admin.ps1')) {
        $Source = Join-Path $StarterPath $Name
        if (-not (Test-Path -LiteralPath $Source)) { throw 'The extracted Starter Kit is missing. Download the ZIP and rerun setup.' }
        Copy-Item -LiteralPath $Source -Destination (Join-Path $RuntimeDir $Name) -Force
    }
    & $PythonPath (Join-Path $RuntimeDir 'livelab_setup.py') configure --project $ProjectPath --runtime $RuntimeDir --python $PythonPath
    if ($LASTEXITCODE -ne 0) { throw 'Project configuration refresh failed.' }
    Write-Host 'Refresh complete. Open this project in Codex and create a new task:'
    Write-Host $ProjectPath
}

function Invoke-LiveLabAction {
    param([string]$SelectedAction)
    switch ($SelectedAction) {
        'Restart' { Stop-LiveLab; Refresh-LiveLab }
        'Stop' { Stop-LiveLab }
        'Status' { Show-LiveLabStatus }
        'Refresh' { Refresh-LiveLab }
    }
}

try {
    if ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) { throw 'Use the .command management script on macOS.' }
    $RuntimeDir = Join-Path $env:LOCALAPPDATA 'peakgear-livelab'
    foreach ($Name in @('project-path', 'python-path', 'starter-path')) {
        if (-not (Test-Path -LiteralPath (Join-Path $RuntimeDir $Name))) { throw 'Run 01-setup-peakgear-mcp.ps1 first.' }
    }
    $ProjectPath = [IO.File]::ReadAllText((Join-Path $RuntimeDir 'project-path')).Trim()
    $PythonPath = [IO.File]::ReadAllText((Join-Path $RuntimeDir 'python-path')).Trim()
    if ($Action -ne 'Menu') { Invoke-LiveLabAction $Action; exit 0 }
    while ($true) {
        Show-LiveLabStatus
        Write-Host '1) Restart PeakGear LiveLab only (recommended)'
        Write-Host '2) Stop PeakGear LiveLab only'
        Write-Host '3) Refresh files and project configuration'
        Write-Host '4) Show status'
        Write-Host '5) Exit'
        switch (Read-Host 'Choose an action [1]') {
            { $_ -eq '' -or $_ -eq '1' } { Invoke-LiveLabAction 'Restart' }
            '2' { Invoke-LiveLabAction 'Stop' }
            '3' { Invoke-LiveLabAction 'Refresh' }
            '4' { Invoke-LiveLabAction 'Status' }
            '5' { exit 0 }
            default { Write-Host 'Choose a number from 1 to 5.' }
        }
    }
} catch {
    Write-Error $_ -ErrorAction Continue
    exit 1
}
