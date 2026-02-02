# ============================================
# Flutter Doctor
# ============================================

param(
    [switch]$Verbose,
    [switch]$Licenses,
    [switch]$Upgrade
)

# Add Flutter to PATH
$env:Path = "C:\flutter\bin;$env:Path"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Flutter Doctor" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($Upgrade) {
    Write-Host "Upgrading Flutter..." -ForegroundColor Yellow
    flutter upgrade
    Write-Host ""
}

if ($Licenses) {
    Write-Host "Accepting Android licenses..." -ForegroundColor Yellow
    flutter doctor --android-licenses
    Write-Host ""
}

if ($Verbose) {
    flutter doctor -v
} else {
    flutter doctor
}
