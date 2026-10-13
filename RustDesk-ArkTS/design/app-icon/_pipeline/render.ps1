# Render an SVG/HTML asset to PNG at an exact pixel size with a transparent background.
# Usage: render.ps1 -In <input .html/.svg> -Out <output .png> -Size 1024
param(
  [Parameter(Mandatory = $true)][string]$In,
  [Parameter(Mandatory = $true)][string]$Out,
  [int]$Size = 1024
)
$ErrorActionPreference = 'Stop'
$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
if (-not (Test-Path $edge)) { throw "Edge not found at $edge" }

$inFull = (Resolve-Path -LiteralPath $In).Path
$outFull = [System.IO.Path]::GetFullPath($Out)
$outDir = Split-Path -Parent $outFull
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }
if (Test-Path $outFull) { Remove-Item -LiteralPath $outFull -Force }

$profile = Join-Path $env:TEMP ('edge-shot-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
$uri = 'file:///' + ($inFull -replace '\\', '/')
$args = @(
  '--headless=new', '--disable-gpu', '--no-first-run', '--no-default-browser-check',
  '--hide-scrollbars', '--force-device-scale-factor=1',
  "--user-data-dir=$profile",
  "--default-background-color=00000000",
  "--window-size=$Size,$Size",
  "--screenshot=$outFull",
  $uri
)
& $edge @args | Out-Null
Start-Sleep -Milliseconds 300
Remove-Item -LiteralPath $profile -Recurse -Force -ErrorAction SilentlyContinue
if (-not (Test-Path $outFull)) { throw "render failed: no output at $outFull" }
"rendered: $outFull ($((Get-Item $outFull).Length) bytes)"
