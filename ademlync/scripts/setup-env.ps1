# ============================================
# Setup Environment - Add Flutter to PATH
# ============================================
# Run this script first in each new terminal session
# Or add Flutter to system PATH permanently

param(
    [switch]$Permanent  # Add to system PATH permanently
)

$FlutterPath = "C:\flutter\bin"

if ($Permanent) {
    Write-Host "Adding Flutter to system PATH permanently..." -ForegroundColor Yellow
    
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    
    if ($currentPath -notlike "*$FlutterPath*") {
        [Environment]::SetEnvironmentVariable("Path", "$currentPath;$FlutterPath", "User")
        Write-Host "Flutter added to user PATH. Restart terminal to apply." -ForegroundColor Green
    } else {
        Write-Host "Flutter already in PATH." -ForegroundColor Green
    }
} else {
    # Add to current session only
    if ($env:Path -notlike "*$FlutterPath*") {
        $env:Path = "$FlutterPath;$env:Path"
        Write-Host "Flutter added to current session PATH." -ForegroundColor Green
    } else {
        Write-Host "Flutter already in session PATH." -ForegroundColor Green
    }
}

# Verify
Write-Host ""
Write-Host "Flutter version:" -ForegroundColor Cyan
flutter --version
