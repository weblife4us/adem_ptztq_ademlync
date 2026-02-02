# ============================================
# Install Dependencies
# ============================================

param(
    [switch]$Clean
)

# Add Flutter to PATH
$env:Path = "C:\flutter\bin;$env:Path"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Installing Dependencies" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$rootDir = "d:\cursor\ademlync"

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
