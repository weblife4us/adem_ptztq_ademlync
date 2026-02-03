# Flutter Clean Only Script
# Use this script to clean build cache without rebuilding

Write-Host "=== Flutter Clean Only ===" -ForegroundColor Cyan

# Navigate to Flutter project directory (parent of scripts folder)
$projectDir = "$PSScriptRoot\.."
Set-Location $projectDir
Write-Host "Working directory: $(Get-Location)" -ForegroundColor Green

# Step 1: Flutter clean
Write-Host "`n[1/3] Running flutter clean..." -ForegroundColor Yellow
flutter clean

# Step 2: Remove build directory
Write-Host "`n[2/3] Removing build directory..." -ForegroundColor Yellow
if (Test-Path "build") {
    Remove-Item -Recurse -Force build -ErrorAction SilentlyContinue
    Write-Host "Build directory removed." -ForegroundColor Green
} else {
    Write-Host "Build directory already clean." -ForegroundColor Green
}

# Step 3: Get dependencies
Write-Host "`n[3/3] Running flutter pub get..." -ForegroundColor Yellow
flutter pub get

Write-Host "`n=== Clean Complete ===" -ForegroundColor Cyan
Write-Host "Run 'flutter run' or 'flutter build apk' to build the project." -ForegroundColor Gray
