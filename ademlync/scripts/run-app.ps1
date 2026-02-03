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

# Change to project directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectDir = Split-Path -Parent $scriptDir
Set-Location $projectDir

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
