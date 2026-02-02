# ============================================
# Quick Start - Full Setup and Run
# ============================================

param(
    [switch]$SkipEmulator,
    [switch]$Web,
    [switch]$Windows
)

# Add Flutter to PATH
$env:Path = "C:\flutter\bin;$env:Path"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "AdEMLync Quick Start" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check Flutter
Write-Host "[1/4] Checking Flutter..." -ForegroundColor Yellow
flutter --version
Write-Host ""

# Step 2: Install dependencies
Write-Host "[2/4] Installing dependencies..." -ForegroundColor Yellow
Set-Location "d:\cursor\ademlync\ademlync"
flutter pub get
Write-Host ""

# Step 3: Start emulator (if needed)
if (-not $SkipEmulator -and -not $Web -and -not $Windows) {
    Write-Host "[3/4] Checking emulator..." -ForegroundColor Yellow
    
    $devices = & flutter devices 2>&1 | Out-String
    if ($devices -match "emulator-\d+") {
        Write-Host "Emulator already running!" -ForegroundColor Green
    } else {
        Write-Host "Starting emulator..." -ForegroundColor Gray
        flutter emulators --launch Pixel_9_Pro_XL
        Write-Host "Waiting for emulator (40 seconds)..." -ForegroundColor Gray
        Start-Sleep -Seconds 40
    }
    Write-Host ""
}

# Step 4: Run app
Write-Host "[4/4] Running application..." -ForegroundColor Yellow

if ($Web) {
    flutter run -d chrome
} elseif ($Windows) {
    flutter run -d windows
} else {
    # Auto-detect emulator
    $devices = & flutter devices 2>&1 | Out-String
    if ($devices -match "emulator-(\d+)") {
        $emulatorId = "emulator-$($Matches[1])"
        Write-Host "Running on: $emulatorId" -ForegroundColor Green
        flutter run -d $emulatorId
    } else {
        flutter run
    }
}
