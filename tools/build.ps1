<#
.SYNOPSIS
    Refreshes the PBLs from the ws_objects source and builds PowerBuilder targets, without the IDE.

.DESCRIPTION
    1. Refresh: imports the source in ws_objects into the target's PBLs and compiles them, the same as
       the IDE's refresh. Uses the "Merging" entries in refresh.json for the selected targets only.
       Every object of the target is imported, so this takes a minute or two.
    2. Build: compiles the target with PBC (incremental unless -Full) and deploys the exe and PBDs
       to build\<target>\.

    PowerBuilder must not have the workspace open, because the IDE keeps the PBLs open.

.PARAMETER Target
    Target names (the .pbt file names without the extension). Default: "peat demo app".
    Separate several with commas: -Target "peat demo app,security administrator".
.PARAMETER All
    Process every .pbt in the workspace.
.PARAMETER NoRefresh
    Skip the refresh (build from the PBLs as they are).
.PARAMETER NoBuild
    Only refresh the PBLs.
.PARAMETER Full
    Full instead of incremental compilation.
.PARAMETER OutDir
    Output folder. Default: build\ in the workspace.

.EXAMPLE
    pwsh -File tools\build.ps1
    pwsh -File tools\build.ps1 -Target "peat demo app,security administrator"
    pwsh -File tools\build.ps1 -All -Full

.NOTES
    Exit codes: 0 = success, 1 = a refresh or build failed, 2 = could not start (bad target,
    PowerBuilder open, PBAutoBuild not found).
#>
[CmdletBinding(PositionalBinding = $false)]
param(
    [string[]]$Target = @('peat demo app'),
    [switch]$All,
    [switch]$NoRefresh,
    [switch]$NoBuild,
    [switch]$Full,
    [string]$OutDir,
    [string]$PBAutoBuild = 'C:\Program Files (x86)\Appeon\PowerBuilder 25.0\pbautobuild250.exe'
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
if (-not $OutDir) { $OutDir = Join-Path $root 'build' }
elseif (-not [IO.Path]::IsPathRooted($OutDir)) { $OutDir = Join-Path (Get-Location) $OutDir }

# PBAutoBuild writes its console output and logs in UTF-16 or UTF-8
function Read-Log([string]$Path) {
    if (-not (Test-Path $Path)) { return '' }
    $bytes = [IO.File]::ReadAllBytes($Path)
    if ($bytes.Length -gt 1 -and $bytes[1] -eq 0) { return [Text.Encoding]::Unicode.GetString($bytes) }
    return [Text.Encoding]::UTF8.GetString($bytes)
}

function Invoke-PBAutoBuild([string[]]$Arguments, [string]$ConsoleLog) {
    Push-Location $root
    try {
        $process = Start-Process -FilePath $PBAutoBuild -ArgumentList $Arguments -NoNewWindow -Wait -PassThru `
            -RedirectStandardOutput $ConsoleLog
        return $process.ExitCode
    } finally {
        Pop-Location
    }
}

# --- Checks -----------------------------------------------------------------
$Target = @($Target | ForEach-Object { $_ -split ',' } | ForEach-Object { $_.Trim() } | Where-Object { $_ })
$available = @(Get-ChildItem $root -Filter *.pbt | ForEach-Object BaseName)
if ($All) { $Target = $available }
$unknown = @($Target | Where-Object { $available -notcontains $_ })
if ($unknown.Count -gt 0) {
    Write-Host "Unknown target(s): $($unknown -join ', '). Available: $($available -join ', ')"
    exit 2
}
if (Get-Process | Where-Object { $_.ProcessName -match '^PB\d{3}$' }) {
    Write-Host "Close PowerBuilder first: the IDE keeps the PBLs open."
    exit 2
}
if (-not (Test-Path $PBAutoBuild)) {
    Write-Host "PBAutoBuild not found: $PBAutoBuild (use -PBAutoBuild)"
    exit 2
}
New-Item -ItemType Directory -Force $OutDir | Out-Null
$failed = $false

# --- Refresh ----------------------------------------------------------------
if (-not $NoRefresh) {
    # Keep the selected targets' Merging entries, with absolute paths, because PBAutoBuild resolves
    # relative paths from the location of the build file
    $plan = Get-Content (Join-Path $root 'refresh.json') -Raw | ConvertFrom-Json
    $merging = @()
    foreach ($entry in $plan.BuildPlan.SourceControl.Merging) {
        $name = [IO.Path]::GetFileNameWithoutExtension($entry.Target)
        if ($Target -contains $name) {
            $merging += [pscustomobject]@{
                Target           = Join-Path $root "$name.pbt"
                LocalProjectPath = $root
                RefreshPbl       = $entry.RefreshPbl
            }
        }
    }
    $plan.BuildPlan.SourceControl.Merging = $merging
    $buildFile = Join-Path $OutDir 'refresh.selected.json'
    $plan | ConvertTo-Json -Depth 10 | Set-Content -Path $buildFile -Encoding UTF8

    Write-Host "Refreshing the PBLs of: $($Target -join ', ')"
    $log = Join-Path $OutDir 'refresh.log'
    $errorLog = Join-Path $OutDir 'refresh_error.log'
    Remove-Item $log, $errorLog -ErrorAction SilentlyContinue
    $started = Get-Date
    $rc = Invoke-PBAutoBuild @('/f', "`"$buildFile`"", '/l', "`"$log`"", '/le', "`"$errorLog`"") (Join-Path $OutDir 'refresh.console.log')
    $errors = (Read-Log $errorLog).Trim()
    if ($rc -ne 0 -or $errors) {
        Write-Host "Refresh failed (exit code $rc); see $log"
        if ($errors) { $errors -split "`r?`n" | Select-Object -First 20 | ForEach-Object { Write-Host "  $_" } }
        exit 1
    }
    Write-Host ("Refreshed in {0:N0} s" -f ((Get-Date) - $started).TotalSeconds)
}

# --- Build ------------------------------------------------------------------
if (-not $NoBuild) {
    foreach ($name in $Target) {
        $pbt = Join-Path $root "$name.pbt"
        $pbtText = Get-Content $pbt -Raw
        $appName = [regex]::Match($pbtText, '(?m)^appname "([^"]+)";').Groups[1].Value
        $libraries = [regex]::Match($pbtText, '(?m)^LibList "([^"]+)";').Groups[1].Value.Replace('\\', '\') -split ';'

        $targetDir = Join-Path $OutDir $name
        New-Item -ItemType Directory -Force $targetDir | Out-Null
        $exe = Join-Path $targetDir "$appName.exe"
        $log = Join-Path $targetDir 'build.log'
        $mode = if ($Full) { '/f' } else { '/i' }

        Write-Host "Building $name ($(if ($Full) { 'full' } else { 'incremental' }))"
        $started = Get-Date
        $rc = Invoke-PBAutoBuild @('/pbc', $mode, '/d', "`"$pbt`"", '/o', "`"$exe`"") $log
        $text = Read-Log $log

        # PBC writes each PBD beside its PBL; keep them with the exe
        foreach ($library in $libraries) {
            $pbd = [IO.Path]::ChangeExtension((Join-Path $root $library), '.pbd')
            if (Test-Path $pbd) { Move-Item $pbd $targetDir -Force }
        }

        if ($rc -ne 0 -or -not (Test-Path $exe)) {
            Write-Host "  Build failed (exit code $rc); see $log"
            $text -split "`r?`n" | Where-Object { $_ -match '\[Error\]|error C' } | Select-Object -First 20 |
                ForEach-Object { Write-Host "  $_" }
            $failed = $true
        } else {
            Write-Host ("  {0} in {1:N0} s" -f $exe, ((Get-Date) - $started).TotalSeconds)
        }
    }
}

if ($failed) { exit 1 }
exit 0
