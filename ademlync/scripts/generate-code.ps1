# ============================================
# Generate Code (build_runner)
# ============================================

param(
    [switch]$Watch,
    [switch]$Delete
)

# Function to find Flutter installation
function Find-Flutter {
    $flutterCmd = Get-Command flutter -ErrorAction SilentlyContinue
    if ($flutterCmd) { return Split-Path $flutterCmd.Source }
    
    $possiblePaths = @(
        "C:\flutter\bin", "C:\src\flutter\bin", "$env:USERPROFILE\flutter\bin",
        "$env:LOCALAPPDATA\flutter\bin", "D:\flutter\bin", "C:\dev\flutter\bin"
    )
    foreach ($path in $possiblePaths) {
        if (Test-Path "$path\flutter.bat") { return $path }
    }
    return $null
}

$FlutterPath = Find-Flutter
if (-not $FlutterPath) {
    Write-Host "[ERROR] Flutter not found!" -ForegroundColor Red
    exit 1
}
if ($env:Path -notlike "*$FlutterPath*") {
    $env:Path = "$FlutterPath;$env:Path"
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Code Generation (build_runner)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectDir = Split-Path -Parent $scriptDir
$rootDir = Split-Path -Parent $projectDir
Set-Location "$rootDir\packages\ademlync_cloud"

$args = @("pub", "run", "build_runner")

if ($Watch) {
    $args += "watch"
    Write-Host "Mode: WATCH (continuous)" -ForegroundColor Yellow
} else {
    $args += "build"
    Write-Host "Mode: BUILD (one-time)" -ForegroundColor Yellow
}

if ($Delete) {
    $args += "--delete-conflicting-outputs"
    Write-Host "Delete conflicting outputs: YES" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Running: flutter $($args -join ' ')" -ForegroundColor Gray
Write-Host ""

& flutter @args

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Code generation complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
