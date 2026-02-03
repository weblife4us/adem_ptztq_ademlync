# ============================================
# Install Dependencies
# ============================================

param(
    [switch]$Clean
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
Write-Host "Installing Dependencies" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Determine root directory (parent of scripts folder, then parent of ademlync)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectDir = Split-Path -Parent $scriptDir
$rootDir = Split-Path -Parent $projectDir

# Clean if requested
if ($Clean) {
    Write-Host "Cleaning projects..." -ForegroundColor Yellow
    
    Set-Location "$rootDir\ademlync"
    flutter clean
    
    Set-Location "$rootDir\packages\ademlync_device"
    flutter clean
    
    Set-Location "$rootDir\packages\ademlync_cloud"
    flutter clean
    
    Write-Host ""
}

# Install main app dependencies
Write-Host "[1/3] Main app (ademlync)..." -ForegroundColor Yellow
Set-Location "$rootDir\ademlync"
flutter pub get
Write-Host ""

# Install device package dependencies
Write-Host "[2/3] Device package (ademlync_device)..." -ForegroundColor Yellow
Set-Location "$rootDir\packages\ademlync_device"
flutter pub get
Write-Host ""

# Install cloud package dependencies
Write-Host "[3/3] Cloud package (ademlync_cloud)..." -ForegroundColor Yellow
Set-Location "$rootDir\packages\ademlync_cloud"
flutter pub get
Write-Host ""

Write-Host "========================================" -ForegroundColor Green
Write-Host "All dependencies installed!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
