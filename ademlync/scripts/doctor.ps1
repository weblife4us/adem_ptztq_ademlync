# ============================================
# Flutter Doctor
# ============================================

param(
    [switch]$Verbose,
    [switch]$Licenses,
    [switch]$Upgrade
)

# Function to find Flutter installation
function Find-Flutter {
    $flutterCmd = Get-Command flutter -ErrorAction SilentlyContinue
    if ($flutterCmd) {
        return Split-Path $flutterCmd.Source
    }
    
    $possiblePaths = @(
        "C:\flutter\bin",
        "C:\src\flutter\bin",
        "$env:USERPROFILE\flutter\bin",
        "$env:LOCALAPPDATA\flutter\bin",
        "D:\flutter\bin",
        "C:\dev\flutter\bin"
    )
    
    foreach ($path in $possiblePaths) {
        if (Test-Path "$path\flutter.bat") {
            return $path
        }
    }
    return $null
}

# Function to find Android SDK
function Find-AndroidSDK {
    if ($env:ANDROID_HOME -and (Test-Path $env:ANDROID_HOME)) {
        return $env:ANDROID_HOME
    }
    if ($env:ANDROID_SDK_ROOT -and (Test-Path $env:ANDROID_SDK_ROOT)) {
        return $env:ANDROID_SDK_ROOT
    }
    
    $possiblePaths = @(
        "$env:LOCALAPPDATA\Android\Sdk",
        "$env:USERPROFILE\AppData\Local\Android\Sdk",
        "C:\Android\Sdk",
        "$env:USERPROFILE\Android\Sdk"
    )
    
    foreach ($path in $possiblePaths) {
        if (Test-Path "$path\emulator") {
            return $path
        }
    }
    return $null
}

# Setup Flutter
$FlutterPath = Find-Flutter
if (-not $FlutterPath) {
    Write-Host "[ERROR] Flutter not found!" -ForegroundColor Red
    Write-Host "Check these locations:" -ForegroundColor Yellow
    Write-Host "  - C:\flutter\bin" -ForegroundColor Gray
    Write-Host "  - $env:USERPROFILE\flutter\bin" -ForegroundColor Gray
    exit 1
}
if ($env:Path -notlike "*$FlutterPath*") {
    $env:Path = "$FlutterPath;$env:Path"
}

# Setup Android SDK
$AndroidSDK = Find-AndroidSDK
if ($AndroidSDK -and -not $env:ANDROID_HOME) {
    $env:ANDROID_HOME = $AndroidSDK
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Flutter Doctor" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Flutter: $FlutterPath" -ForegroundColor Gray
if ($AndroidSDK) {
    Write-Host "Android SDK: $AndroidSDK" -ForegroundColor Gray
} else {
    Write-Host "Android SDK: NOT FOUND (set ANDROID_HOME)" -ForegroundColor Yellow
}
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
