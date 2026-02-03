# ============================================
# Run Android Emulator
# ============================================

param(
    [string]$EmulatorName,    # AVD name (auto-detect if not specified)
    [switch]$List,
    [switch]$ColdBoot,
    [string]$AndroidSDKPath   # Manual path to Android SDK
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
    param([string]$ManualPath)
    
    if ($ManualPath -and (Test-Path $ManualPath)) {
        return $ManualPath
    }
    
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
        "D:\Android\Sdk",
        "E:\Android\Sdk",
        "$env:USERPROFILE\Android\Sdk",
        "C:\Program Files\Android\Sdk",
        "C:\dev\android-sdk",
        "D:\dev\android-sdk"
    )
    
    foreach ($path in $possiblePaths) {
        if ($path -and (Test-Path "$path\emulator")) {
            return $path
        }
        if ($path -and (Test-Path "$path\platform-tools")) {
            return $path
        }
    }
    return $null
}

# Function to get all AVDs from .android/avd folder
function Get-AVDsFromFolder {
    $avdDir = "$env:USERPROFILE\.android\avd"
    if (Test-Path $avdDir) {
        # Look for .ini files (they contain the real AVD name)
        # Each AVD has: Name.ini (config) and Name.avd/ (folder)
        $avdIniFiles = Get-ChildItem "$avdDir\*.ini" -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -notmatch "\.avd\.ini$" -and $_.Name -match "\.ini$" }
        if ($avdIniFiles) {
            return $avdIniFiles | ForEach-Object { $_.BaseName }
        }
        # Fallback: folder names without .avd extension
        $avdFolders = Get-ChildItem "$avdDir\*.avd" -Directory -ErrorAction SilentlyContinue
        return $avdFolders | ForEach-Object { $_.Name -replace '\.avd$', '' }
    }
    return @()
}

# Function to get first available AVD
function Get-FirstAVD {
    $avds = Get-AVDsFromFolder
    if ($avds -and $avds.Count -gt 0) {
        return $avds[0]
    }
    return $null
}

# Setup Flutter
$FlutterPath = Find-Flutter
if (-not $FlutterPath) {
    Write-Host "[ERROR] Flutter not found!" -ForegroundColor Red
    exit 1
}
if ($env:Path -notlike "*$FlutterPath*") {
    $env:Path = "$FlutterPath;$env:Path"
}

# Setup Android SDK
$AndroidSDK = Find-AndroidSDK -ManualPath $AndroidSDKPath
if ($AndroidSDK) {
    if (-not $env:ANDROID_HOME) {
        $env:ANDROID_HOME = $AndroidSDK
    }
    $emulatorPath = "$AndroidSDK\emulator"
    $platformToolsPath = "$AndroidSDK\platform-tools"
    if ($env:Path -notlike "*$emulatorPath*") {
        $env:Path = "$emulatorPath;$platformToolsPath;$env:Path"
    }
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Android Emulator Manager" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Show detected paths
Write-Host "Flutter: $FlutterPath" -ForegroundColor Gray
if ($AndroidSDK) {
    Write-Host "Android SDK: $AndroidSDK" -ForegroundColor Gray
} else {
    Write-Host "Android SDK: NOT FOUND" -ForegroundColor Red
    Write-Host "Set ANDROID_HOME or install Android Studio" -ForegroundColor Yellow
}
Write-Host ""

if ($List) {
    Write-Host "AVDs from folder ($env:USERPROFILE\.android\avd):" -ForegroundColor Yellow
    $avds = Get-AVDsFromFolder
    if ($avds) {
        foreach ($avd in $avds) {
            Write-Host "  - $avd" -ForegroundColor Green
        }
    } else {
        Write-Host "  (none found)" -ForegroundColor Gray
    }
    Write-Host ""
    
    Write-Host "Flutter emulators:" -ForegroundColor Yellow
    flutter emulators
    
    if ($AndroidSDK) {
        Write-Host ""
        Write-Host "Emulator -list-avds:" -ForegroundColor Yellow
        $emulatorExe = "$AndroidSDK\emulator\emulator.exe"
        if (Test-Path $emulatorExe) {
            & $emulatorExe -list-avds
        } else {
            Write-Host "  emulator.exe not found" -ForegroundColor Red
        }
    }
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

# Auto-detect AVD if not specified
if (-not $EmulatorName) {
    $EmulatorName = Get-FirstAVD
    if (-not $EmulatorName) {
        Write-Host "[ERROR] No AVD found!" -ForegroundColor Red
        Write-Host ""
        Write-Host "Create AVD in Android Studio: Tools > Device Manager" -ForegroundColor Yellow
        Write-Host "Or specify manually: .\run-emulator.ps1 -EmulatorName 'YourAVDName'" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "To see available AVDs: .\run-emulator.ps1 -List" -ForegroundColor Gray
        exit 1
    }
}

Write-Host "Available AVDs:" -ForegroundColor Gray
Get-AVDsFromFolder | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }
Write-Host ""
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
