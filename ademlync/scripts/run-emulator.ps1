# ============================================
# Run Android Emulator
# ============================================

param(
    [string]$EmulatorName = "Pixel_9_Pro_XL",
    [switch]$List,
    [switch]$ColdBoot
)

# Add Flutter to PATH
$env:Path = "C:\flutter\bin;$env:Path"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Android Emulator Manager" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($List) {
    Write-Host "Available emulators:" -ForegroundColor Yellow
    flutter emulators
    exit 0
}

# Check if emulator already running
$devices = & flutter devices 2>&1 | Out-String
if ($devices -match "emulator-\d+") {
    Write-Host "Emulator already running!" -ForegroundColor Green
    Write-Host ""
    flutter devices
    exit 0
}

Write-Host "Starting emulator: $EmulatorName" -ForegroundColor Yellow
Write-Host ""

if ($ColdBoot) {
    flutter emulators --launch $EmulatorName --cold
} else {
    flutter emulators --launch $EmulatorName
}

Write-Host ""
Write-Host "Waiting for emulator to boot (40 seconds)..." -ForegroundColor Gray
Start-Sleep -Seconds 40

Write-Host ""
Write-Host "Connected devices:" -ForegroundColor Green
flutter devices
