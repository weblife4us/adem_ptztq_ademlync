# ============================================
# Run Tests
# ============================================

param(
    [switch]$Coverage,
    [string]$Filter
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
Write-Host "Running Tests" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectDir = Split-Path -Parent $scriptDir
$rootDir = Split-Path -Parent $projectDir

# Test main app
Write-Host "[1/3] Testing main app..." -ForegroundColor Yellow
Set-Location "$rootDir\ademlync"

$args = @("test")
if ($Coverage) { $args += "--coverage" }
if ($Filter) { $args += "--name", $Filter }

& flutter @args
Write-Host ""

# Test device package
Write-Host "[2/3] Testing ademlync_device..." -ForegroundColor Yellow
Set-Location "$rootDir\packages\ademlync_device"
& flutter @args
Write-Host ""

# Test cloud package
Write-Host "[3/3] Testing ademlync_cloud..." -ForegroundColor Yellow
Set-Location "$rootDir\packages\ademlync_cloud"
& flutter @args

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Tests complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
