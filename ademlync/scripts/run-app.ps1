# ============================================
# Run Application
# ============================================

param(
    [string]$Device,
    [switch]$Release,
    [switch]$Profile,
    [switch]$Web,
    [switch]$Windows,
    [switch]$ListDevices
)

# Add Flutter to PATH
$env:Path = "C:\flutter\bin;$env:Path"

# Change to project directory
Set-Location "d:\cursor\ademlync\ademlync"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "AdEMLync Application Runner" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($ListDevices) {
    Write-Host "Connected devices:" -ForegroundColor Yellow
    flutter devices
    exit 0
}

# Auto-detect emulator if no device specified
if (-not $Device -and -not $Web -and -not $Windows) {
    $devices = & flutter devices 2>&1 | Out-String
    if ($devices -match "emulator-(\d+)") {
        $Device = "emulator-$($Matches[1])"
        Write-Host "Auto-detected emulator: $Device" -ForegroundColor Green
    }
}

# Build arguments
$args = @("run")

if ($Device) {
    $args += "-d", $Device
} elseif ($Web) {
    $args += "-d", "chrome"
} elseif ($Windows) {
    $args += "-d", "windows"
}

if ($Release) {
    $args += "--release"
    Write-Host "Mode: RELEASE" -ForegroundColor Magenta
} elseif ($Profile) {
    $args += "--profile"
    Write-Host "Mode: PROFILE" -ForegroundColor Magenta
} else {
    Write-Host "Mode: DEBUG" -ForegroundColor Magenta
}

Write-Host "Running: flutter $($args -join ' ')" -ForegroundColor Gray
Write-Host ""

# Run the app
& flutter @args
