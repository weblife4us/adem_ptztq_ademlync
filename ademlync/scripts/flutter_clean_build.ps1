# ============================================
# Flutter Clean Build Script
# ============================================
# Use this script when you get Kotlin incremental cache errors
# (e.g., "this and base files have different roots")
#
# Usage:
#   .\flutter_clean_build.ps1           # Normal clean build
#   .\flutter_clean_build.ps1 -Log      # Save output to log file
#   .\flutter_clean_build.ps1 -NoBuild  # Clean only, don't run
# ============================================

param(
    [switch]$Log,      # Save output to log file for analysis
    [switch]$NoBuild   # Clean only, don't build/run
)

# Setup logging if requested
$LogFile = $null
if ($Log) {
    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $logsDir = "$PSScriptRoot\logs"
    if (-not (Test-Path $logsDir)) {
        New-Item -ItemType Directory -Path $logsDir -Force | Out-Null
    }
    $LogFile = "$logsDir\clean_build_$timestamp.log"
    Start-Transcript -Path $LogFile -Append
    Write-Host "[LOG] Output saved to: $LogFile" -ForegroundColor Magenta
    Write-Host ""
}

Write-Host "=== Flutter Clean Build ===" -ForegroundColor Cyan

# Navigate to Flutter project directory (parent of scripts folder)
$projectDir = "$PSScriptRoot\.."
Set-Location $projectDir
Write-Host "Working directory: $(Get-Location)" -ForegroundColor Green

# Step 1: Flutter clean
Write-Host "`n[1/5] Running flutter clean..." -ForegroundColor Yellow
flutter clean

# Step 2: Remove build directory (if still exists)
Write-Host "`n[2/5] Removing build directory..." -ForegroundColor Yellow
if (Test-Path "build") {
    Remove-Item -Recurse -Force build -ErrorAction SilentlyContinue
    Write-Host "Build directory removed." -ForegroundColor Green
} else {
    Write-Host "Build directory already clean." -ForegroundColor Green
}

# Step 3: Remove Android Gradle cache (fixes Kotlin multi-root issues)
Write-Host "`n[3/5] Cleaning Android Gradle cache..." -ForegroundColor Yellow
$androidGradle = "$projectDir\android\.gradle"
if (Test-Path $androidGradle) {
    Remove-Item -Recurse -Force $androidGradle -ErrorAction SilentlyContinue
    Write-Host "Android Gradle cache removed." -ForegroundColor Green
} else {
    Write-Host "Android Gradle cache already clean." -ForegroundColor Green
}

# Step 4: Get dependencies
Write-Host "`n[4/5] Running flutter pub get..." -ForegroundColor Yellow
flutter pub get

# Step 5: Build/Run (unless NoBuild specified)
if (-not $NoBuild) {
    Write-Host "`n[5/5] Starting flutter run..." -ForegroundColor Yellow
    flutter run
} else {
    Write-Host "`n[5/5] Skipping build (NoBuild flag set)" -ForegroundColor Gray
}

Write-Host "`n=== Build Complete ===" -ForegroundColor Cyan

# Stop logging if enabled
if ($Log) {
    Write-Host "Log saved to: $LogFile" -ForegroundColor Magenta
    Stop-Transcript
}
