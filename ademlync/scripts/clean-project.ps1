# ============================================
# Clean Project
# ============================================

param(
    [switch]$Deep
)

# Add Flutter to PATH
$env:Path = "C:\flutter\bin;$env:Path"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Cleaning Project" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$rootDir = "d:\cursor\ademlync"

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
