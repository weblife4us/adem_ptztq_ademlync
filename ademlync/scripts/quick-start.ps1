# ============================================
# Quick Start - Full Setup and Run
# ============================================
# Usage:
#   .\quick-start.ps1                    # Normal run
#   .\quick-start.ps1 -Log               # Save output to log file
#   .\quick-start.ps1 -Log -Verbose      # Detailed logging
#   .\quick-start.ps1 -Clean             # Clean build first
#   .\quick-start.ps1 -SkipEmulator      # Skip emulator startup
# ============================================

param(
    [switch]$SkipEmulator,
    [switch]$Web,
    [switch]$Windows,
    [switch]$Log,             # Save output to log file for analysis
    [switch]$Clean,           # Run flutter clean before build
    [string]$AVD,             # Specify AVD name manually
    [string]$AndroidSDKPath   # Manual path to Android SDK
)

# Setup logging if requested
$LogFile = $null
$OriginalOut = $null
if ($Log) {
    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $logsDir = "$scriptDir\logs"
    if (-not (Test-Path $logsDir)) {
        New-Item -ItemType Directory -Path $logsDir -Force | Out-Null
    }
    $LogFile = "$logsDir\build_$timestamp.log"
    
    # Start transcript for full logging
    Start-Transcript -Path $LogFile -Append
    Write-Host "[LOG] Output saved to: $LogFile" -ForegroundColor Magenta
    Write-Host ""
}

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
    
    # Check manual path first
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

# Function to get first available AVD
function Get-FirstAVD {
    $avdDir = "$env:USERPROFILE\.android\avd"
    if (Test-Path $avdDir) {
        # Look for .ini files (they contain the real AVD name without .avd extension)
        $avdIniFiles = Get-ChildItem "$avdDir\*.ini" -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -notmatch "\.avd\.ini$" -and $_.Name -match "\.ini$" }
        if ($avdIniFiles) {
            # Remove .ini extension to get AVD name
            return $avdIniFiles[0].BaseName
        }
        # Fallback: use folder name without .avd
        $avdFolders = Get-ChildItem "$avdDir\*.avd" -Directory -ErrorAction SilentlyContinue
        if ($avdFolders) {
            $name = $avdFolders[0].Name -replace '\.avd$', ''
            return $name
        }
    }
    return $null
}

# Function to list all AVDs
function Get-AllAVDs {
    $avdDir = "$env:USERPROFILE\.android\avd"
    if (Test-Path $avdDir) {
        # Look for .ini files (real AVD names)
        $avdIniFiles = Get-ChildItem "$avdDir\*.ini" -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -notmatch "\.avd\.ini$" -and $_.Name -match "\.ini$" }
        if ($avdIniFiles) {
            return $avdIniFiles | ForEach-Object { $_.BaseName }
        }
        # Fallback: folder names without .avd
        $avdFolders = Get-ChildItem "$avdDir\*.avd" -Directory -ErrorAction SilentlyContinue
        return $avdFolders | ForEach-Object { $_.Name -replace '\.avd$', '' }
    }
    return @()
}

# Function to find Java/JDK
function Find-JavaHome {
    if ($env:JAVA_HOME -and (Test-Path "$env:JAVA_HOME\bin\java.exe")) {
        return $env:JAVA_HOME
    }
    
    # Android Studio bundled JDK
    $androidStudioJdkPaths = @(
        "$env:ProgramFiles\Android\Android Studio\jbr",
        "$env:ProgramFiles\Android\Android Studio\jre",
        "${env:ProgramFiles(x86)}\Android\Android Studio\jbr",
        "$env:LOCALAPPDATA\Programs\Android Studio\jbr"
    )
    
    foreach ($path in $androidStudioJdkPaths) {
        if (Test-Path "$path\bin\java.exe") {
            return $path
        }
    }
    
    # Standard JDK locations
    if (Test-Path "$env:ProgramFiles\Java") {
        $jdkDirs = Get-ChildItem "$env:ProgramFiles\Java" -Directory -ErrorAction SilentlyContinue | 
                   Where-Object { $_.Name -match "jdk" } | Sort-Object Name -Descending
        if ($jdkDirs) {
            return $jdkDirs[0].FullName
        }
    }
    
    return $null
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "AdEMLync Quick Start" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Find and setup Flutter
$FlutterPath = Find-Flutter
if (-not $FlutterPath) {
    Write-Host "[ERROR] Flutter not found!" -ForegroundColor Red
    Write-Host "Install Flutter or run: .\setup-env.ps1 -Diagnose" -ForegroundColor Yellow
    exit 1
}

if ($env:Path -notlike "*$FlutterPath*") {
    $env:Path = "$FlutterPath;$env:Path"
}

# Find and setup Android SDK
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

# Find and setup Java
$JavaHome = Find-JavaHome
if ($JavaHome) {
    if (-not $env:JAVA_HOME) {
        $env:JAVA_HOME = $JavaHome
    }
    $javaBin = "$JavaHome\bin"
    if ($env:Path -notlike "*$javaBin*") {
        $env:Path = "$javaBin;$env:Path"
    }
}

# Step 1: Check Flutter
Write-Host "[1/4] Checking environment..." -ForegroundColor Yellow
Write-Host "Flutter: $FlutterPath" -ForegroundColor Gray
if ($AndroidSDK) {
    Write-Host "Android SDK: $AndroidSDK" -ForegroundColor Gray
} else {
    Write-Host "Android SDK: NOT FOUND - run: .\setup-env.ps1 -Diagnose" -ForegroundColor Red
}
if ($JavaHome) {
    Write-Host "Java: $JavaHome" -ForegroundColor Gray
} else {
    Write-Host "Java: NOT FOUND - Gradle may fail!" -ForegroundColor Red
    Write-Host "       Set JAVA_HOME or install JDK" -ForegroundColor Yellow
}
flutter --version
Write-Host ""

# Step 2: Clean (if requested) and Install dependencies
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectDir = Split-Path -Parent $scriptDir
Set-Location $projectDir

if ($Clean) {
    Write-Host "[2/5] Cleaning project..." -ForegroundColor Yellow
    flutter clean
    if (Test-Path "build") {
        Remove-Item -Recurse -Force build -ErrorAction SilentlyContinue
    }
    # Also clean android build cache to fix Kotlin cache issues
    $androidBuildDir = "$projectDir\android\.gradle"
    if (Test-Path $androidBuildDir) {
        Write-Host "Cleaning Android Gradle cache..." -ForegroundColor Gray
        Remove-Item -Recurse -Force $androidBuildDir -ErrorAction SilentlyContinue
    }
    Write-Host ""
    Write-Host "[3/5] Installing dependencies..." -ForegroundColor Yellow
} else {
    Write-Host "[2/4] Installing dependencies..." -ForegroundColor Yellow
}

flutter pub get
Write-Host ""

# Step 3/4: Start emulator (if needed)
if (-not $SkipEmulator -and -not $Web -and -not $Windows) {
    $stepNum = if ($Clean) { "[4/5]" } else { "[3/4]" }
    Write-Host "$stepNum Checking emulator..." -ForegroundColor Yellow
    
    $devices = & flutter devices 2>&1 | Out-String
    if ($devices -match "emulator-\d+") {
        Write-Host "Emulator already running!" -ForegroundColor Green
    } else {
        # Get AVD name
        if (-not $AVD) {
            $AVD = Get-FirstAVD
        }
        
        if ($AVD) {
            Write-Host "Available AVDs:" -ForegroundColor Gray
            Get-AllAVDs | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }
            Write-Host ""
            Write-Host "Starting emulator: $AVD" -ForegroundColor Yellow
            flutter emulators --launch $AVD
            Write-Host "Waiting for emulator (40 seconds)..." -ForegroundColor Gray
            Start-Sleep -Seconds 40
        } else {
            Write-Host "[WARN] No AVD found!" -ForegroundColor Yellow
            Write-Host "Create AVD in Android Studio: Tools > Device Manager" -ForegroundColor Gray
            Write-Host "Or specify AVD name: .\quick-start.ps1 -AVD 'YourAVDName'" -ForegroundColor Gray
            Write-Host ""
            Write-Host "Checking flutter emulators..." -ForegroundColor Gray
            flutter emulators
            Write-Host ""
        }
    }
    Write-Host ""
}

# Step 4/5: Run app
$stepNum = if ($Clean) { "[5/5]" } else { "[4/4]" }
Write-Host "$stepNum Running application..." -ForegroundColor Yellow

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
        Write-Host "No emulator detected. Available devices:" -ForegroundColor Yellow
        flutter devices
        Write-Host ""
        Write-Host "Use -Web for Chrome, -Windows for desktop, or start emulator first" -ForegroundColor Gray
    }
}

# Stop logging if enabled
if ($Log) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Log saved to: $LogFile" -ForegroundColor Magenta
    Write-Host "========================================" -ForegroundColor Cyan
    Stop-Transcript
}
