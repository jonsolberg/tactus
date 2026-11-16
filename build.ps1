# Tactus - build script for Windows (PowerShell)
# Copyright (C) 2026 Jon Solberg - GPL v3 or later, see LICENSE.
#
# Builds:
#   bin\Tactus-<device>.prg   to copy to a watch (default: fenix7)
#   bin\Tactus.iq             the package you upload to the Connect IQ Store
#
# Usage (from the project folder):
#   .\build.ps1 -Key C:\Users\jon\garmin\developer_key.der
#   .\build.ps1 -Key ...\developer_key.der -Device fenix7pro
#   .\build.ps1 -Key ...\developer_key.der -PrgOnly
#
# If Windows refuses to run the script, run this once in the same window:
#   Set-ExecutionPolicy -Scope Process Bypass

param(
    [Parameter(Mandatory = $true)][string]$Key,
    [string]$Device = "fenix7",
    [switch]$PrgOnly
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

if (-not (Test-Path $Key)) {
    throw "Developer key not found: $Key  (create one in VS Code: 'Monkey C: Generate a Developer Key')"
}

# Find the active SDK chosen in the Connect IQ SDK Manager
$cfg = Join-Path $env:APPDATA "Garmin\ConnectIQ\current-sdk.cfg"
if (-not (Test-Path $cfg)) {
    throw "No active Connect IQ SDK found. Open the SDK Manager, download an SDK and click 'Use as active SDK'."
}
$sdk = (Get-Content $cfg -Raw).Trim()
$monkeyc = Join-Path $sdk "bin\monkeyc.bat"
if (-not (Test-Path $monkeyc)) { throw "monkeyc not found in $sdk" }
Write-Host "Using SDK: $sdk"

New-Item -ItemType Directory -Force -Path bin | Out-Null

# 1. A .prg for your own watch
$prg = "bin\Tactus-$Device.prg"
Write-Host "`nBuilding $prg ..."
& $monkeyc -d $Device -f monkey.jungle -o $prg -y $Key -r -w
if ($LASTEXITCODE -ne 0) { throw "Build for $Device failed." }
Write-Host "OK: $prg  -> copy it to GARMIN\APPS on the watch"

if ($PrgOnly) { exit 0 }

# 2. The store package (.iq) for every watch in manifest.xml
#    Needs the device files for ALL those watches in the SDK Manager.
Write-Host "`nExporting bin\Tactus.iq for all watches in manifest.xml ..."
& $monkeyc -e -f monkey.jungle -o bin\Tactus.iq -y $Key -r -w
if ($LASTEXITCODE -ne 0) {
    throw "Export failed. Usually a watch in manifest.xml whose device files are not downloaded - download them in the SDK Manager, or remove that watch from manifest.xml."
}
Write-Host "OK: bin\Tactus.iq  -> upload it at https://apps.garmin.com/developer/upload"
