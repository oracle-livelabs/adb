# Offline syntax and action-routing checks; no install, password, or live database.
# Run with Windows PowerShell 5.1 or PowerShell 7:
# powershell.exe -NoProfile -File .\documentation\tests\test_windows_scripts.ps1

$ErrorActionPreference = 'Stop'
$Starter = Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) 'starter-kit'
$Parsed = @{}
foreach ($Name in @('01-setup-peakgear-mcp.ps1', '02-peakgear-livelab-admin.ps1')) {
    $Tokens = $null
    $Errors = $null
    $Ast = [Management.Automation.Language.Parser]::ParseFile((Join-Path $Starter $Name), [ref]$Tokens, [ref]$Errors)
    if ($Errors.Count -gt 0) { throw ($Errors | Out-String) }
    $Parsed[$Name] = $Ast
    Write-Output "PASS syntax: $Name"
}

$InvokeChecked = $Parsed['01-setup-peakgear-mcp.ps1'].Find({ param($Node) $Node -is [Management.Automation.Language.FunctionDefinitionAst] -and $Node.Name -eq 'Invoke-Checked' }, $true)
. ([scriptblock]::Create($InvokeChecked.Extent.Text))
if ([Environment]::OSVersion.Platform -eq [PlatformID]::Win32NT) {
    $Program = 'cmd.exe'
    $SuccessArgs = @('/c', 'exit 0')
    $FailureArgs = @('/c', 'exit 7')
} else {
    $Program = '/bin/sh'
    $SuccessArgs = @('-c', 'exit 0')
    $FailureArgs = @('-c', 'exit 7')
}
Invoke-Checked -Program $Program -Arguments $SuccessArgs
$FailedAsExpected = $false
try { Invoke-Checked -Program $Program -Arguments $FailureArgs } catch { $FailedAsExpected = $true }
if (-not $FailedAsExpected) { throw 'Failed native commands must stop setup.' }
Write-Output 'PASS setup detects native-command failures'

$ActionRouter = $Parsed['02-peakgear-livelab-admin.ps1'].Find({ param($Node) $Node -is [Management.Automation.Language.FunctionDefinitionAst] -and $Node.Name -eq 'Invoke-LiveLabAction' }, $true)
. ([scriptblock]::Create($ActionRouter.Extent.Text))
function Stop-LiveLab { $script:Stopped += 1 }
function Refresh-LiveLab { $script:Refreshed += 1 }
function Show-LiveLabStatus { $script:Shown += 1 }
$script:Stopped = 0
$script:Refreshed = 0
$script:Shown = 0
Invoke-LiveLabAction 'Restart'
Invoke-LiveLabAction 'Stop'
Invoke-LiveLabAction 'Refresh'
Invoke-LiveLabAction 'Status'
if ($script:Stopped -ne 2 -or $script:Refreshed -ne 2 -or $script:Shown -ne 1) { throw 'Management actions routed incorrectly.' }
Write-Output 'PASS restart, stop, refresh, and status route correctly'

# Exercise the real cleanup function with mocked process operations only.
$StopFunction = $Parsed['02-peakgear-livelab-admin.ps1'].Find({ param($Node) $Node -is [Management.Automation.Language.FunctionDefinitionAst] -and $Node.Name -eq 'Stop-LiveLab' }, $true)
. ([scriptblock]::Create($StopFunction.Extent.Text))
function Get-LiveLabProcesses { @([pscustomobject]@{ ProcessId = 111 }, [pscustomobject]@{ ProcessId = 222 }) }
function Stop-Process {
    param([int]$Id, [string]$ErrorAction)
    if ($Id -eq 111) { throw 'synthetic process already exited or access denied' }
}
function Get-Process {
    param([int]$Id, [string]$ErrorAction)
    if ($script:StillAlive) { [pscustomobject]@{ Id = $Id } }
}
$script:StillAlive = $false
Stop-LiveLab
Write-Output 'PASS already-exited launcher PID does not abort cleanup'
$script:StillAlive = $true
$DeniedAsExpected = $false
try { Stop-LiveLab } catch { $DeniedAsExpected = $true }
if (-not $DeniedAsExpected) { throw 'Cleanup must not hide an error when the target PID is still alive.' }
Write-Output 'PASS cleanup propagates failures for still-running processes'
Write-Output 'No setup scripts, OS credential operations, or process cleanup were executed.'
# The deliberately failed native command above is an assertion, not the test
# result. Do not let its LASTEXITCODE make the GitHub PowerShell step fail.
exit 0
