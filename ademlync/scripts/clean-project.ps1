# ============================================
# Clean Project
# ============================================

param(
    [switch]$Deep
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
Write-Host "Cleaning Project" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectDir = Split-Path -Parent $scriptDir
$rootDir = Split-Path -Parent $projectDir

# Clean main app
Write-Host "[1/3] Cleaning main app..." -ForegroundColor Yellow
Set-Location "$rootDir\ademlync"
flutter clean

# Clean device package
Write-Host "[2/3] Cleaning ademlync_device..." -ForegroundColor Yellow
Set-Location "$rootDir\packages\ademlync_device"
flutter clean

# Clean cloud package
Write-Host "[3/3] Cleaning ademlync_cloud..." -ForegroundColor Yellow
Set-Location "$rootDir\packages\ademlync_cloud"
flutter clean

if ($Deep) {
    Write-Host ""
    Write-Host "Deep clean: Removing lock files and generated code..." -ForegroundColor Magenta
    
    Remove-Item "$rootDir\ademlync\pubspec.lock" -ErrorAction SilentlyContinue
    Remove-Item "$rootDir\packages\ademlync_device\pubspec.lock" -ErrorAction SilentlyContinue
    Remove-Item "$rootDir\packages\ademlync_cloud\pubspec.lock" -ErrorAction SilentlyContinue
    
    # Remove generated files
    Get-ChildItem "$rootDir\packages\ademlync_cloud\lib" -Recurse -Filter "*.g.dart" | Remove-Item -Force
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Clean complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
