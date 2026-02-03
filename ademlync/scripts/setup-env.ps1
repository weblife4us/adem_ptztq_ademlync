# ============================================
# Setup Environment - Auto-detect Flutter and Android SDK
# ============================================
# Run this script first in each new terminal session
# Or add Flutter to system PATH permanently

param(
    [switch]$Permanent,  # Add to system PATH permanently
    [switch]$Diagnose,   # Show detailed diagnostics
    [string]$AndroidSDKPath,  # Manual path to Android SDK
    [string]$FlutterPath      # Manual path to Flutter
)

# Function to find Flutter installation
function Find-Flutter {
    # Check if already in PATH
    $flutterCmd = Get-Command flutter -ErrorAction SilentlyContinue
    if ($flutterCmd) {
        return Split-Path $flutterCmd.Source
    }
    
    # Common Flutter locations
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
    
    # Check environment variables
    if ($env:ANDROID_HOME -and (Test-Path $env:ANDROID_HOME)) {
        return $env:ANDROID_HOME
    }
    if ($env:ANDROID_SDK_ROOT -and (Test-Path $env:ANDROID_SDK_ROOT)) {
        return $env:ANDROID_SDK_ROOT
    }
    
    # Common Android SDK locations (expanded list)
    $possiblePaths = @(
        "$env:LOCALAPPDATA\Android\Sdk",
        "$env:USERPROFILE\AppData\Local\Android\Sdk",
        "C:\Android\Sdk",
        "C:\Android\android-sdk",
        "C:\Users\$env:USERNAME\Android\Sdk",
        "$env:USERPROFILE\Android\Sdk",
        "D:\Android\Sdk",
        "D:\Android\android-sdk",
        "E:\Android\Sdk",
        "C:\Program Files\Android\Sdk",
        "C:\Program Files (x86)\Android\android-sdk",
        "$env:USERPROFILE\AppData\Local\Android\sdk",
        "C:\sdk\android",
        "D:\sdk\android",
        "C:\dev\android-sdk",
        "D:\dev\android-sdk"
    )
    
    foreach ($path in $possiblePaths) {
        if ($path -and (Test-Path "$path\emulator")) {
            return $path
        }
        # Also check without emulator folder (some SDK installs)
        if ($path -and (Test-Path "$path\platform-tools")) {
            return $path
        }
    }
    
    return $null
}

# Function to find AVD directory
function Find-AVDDirectory {
    $possiblePaths = @(
        "$env:USERPROFILE\.android\avd",
        "$env:ANDROID_AVD_HOME"
    )
    
    foreach ($path in $possiblePaths) {
        if ($path -and (Test-Path $path)) {
            return $path
        }
    }
    
    return $null
}

# Function to find Java/JDK
function Find-JavaHome {
    # Check if already set
    if ($env:JAVA_HOME -and (Test-Path "$env:JAVA_HOME\bin\java.exe")) {
        return $env:JAVA_HOME
    }
    
    # Android Studio bundled JDK (most common)
    $androidStudioJdkPaths = @(
        "$env:ProgramFiles\Android\Android Studio\jbr",
        "$env:ProgramFiles\Android\Android Studio\jre",
        "${env:ProgramFiles(x86)}\Android\Android Studio\jbr",
        "${env:ProgramFiles(x86)}\Android\Android Studio\jre",
        "$env:LOCALAPPDATA\Programs\Android Studio\jbr"
    )
    
    foreach ($path in $androidStudioJdkPaths) {
        if (Test-Path "$path\bin\java.exe") {
            return $path
        }
    }
    
    # Standard JDK locations
    $jdkPaths = @(
        "$env:ProgramFiles\Java",
        "$env:ProgramFiles\Eclipse Adoptium",
        "$env:ProgramFiles\Microsoft\jdk*",
        "$env:ProgramFiles\Zulu",
        "C:\Java",
        "D:\Java",
        "E:\Java"
    )
    
    foreach ($basePath in $jdkPaths) {
        if (Test-Path $basePath) {
            $jdkDirs = Get-ChildItem $basePath -Directory -ErrorAction SilentlyContinue | 
                       Where-Object { $_.Name -match "jdk|jbr|zulu" } |
                       Sort-Object Name -Descending
            foreach ($dir in $jdkDirs) {
                if (Test-Path "$($dir.FullName)\bin\java.exe") {
                    return $dir.FullName
                }
            }
        }
    }
    
    # Check if java is in PATH
    $javaCmd = Get-Command java -ErrorAction SilentlyContinue
    if ($javaCmd) {
        $javaPath = Split-Path (Split-Path $javaCmd.Source)
        if (Test-Path "$javaPath\bin\java.exe") {
            return $javaPath
        }
    }
    
    return $null
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "AdEMLync Environment Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Find Flutter (use manual path if provided)
$FoundFlutter = if ($FlutterPath -and (Test-Path "$FlutterPath\flutter.bat")) { $FlutterPath } else { Find-Flutter }
if ($FoundFlutter) {
    Write-Host "[OK] Flutter found: $FoundFlutter" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Flutter not found!" -ForegroundColor Red
    Write-Host "Please install Flutter and add to PATH or install to:" -ForegroundColor Yellow
    Write-Host "  - C:\flutter\" -ForegroundColor Gray
    Write-Host "  - $env:USERPROFILE\flutter\" -ForegroundColor Gray
    Write-Host "Or specify path: .\setup-env.ps1 -FlutterPath 'C:\path\to\flutter\bin'" -ForegroundColor Yellow
}

# Find Android SDK (use manual path if provided)
$AndroidSDK = Find-AndroidSDK -ManualPath $AndroidSDKPath
if ($AndroidSDK) {
    Write-Host "[OK] Android SDK found: $AndroidSDK" -ForegroundColor Green
    
    # Set environment variable if not set
    if (-not $env:ANDROID_HOME) {
        $env:ANDROID_HOME = $AndroidSDK
        Write-Host "     Set ANDROID_HOME=$AndroidSDK" -ForegroundColor Gray
    }
} else {
    Write-Host "[ERROR] Android SDK not found!" -ForegroundColor Red
    Write-Host "Options:" -ForegroundColor Yellow
    Write-Host "  1. Specify path manually:" -ForegroundColor Gray
    Write-Host "     .\setup-env.ps1 -AndroidSDKPath 'D:\your\path\to\Sdk'" -ForegroundColor Cyan
    Write-Host "  2. Set environment variable:" -ForegroundColor Gray
    Write-Host "     `$env:ANDROID_HOME = 'D:\your\path\to\Sdk'" -ForegroundColor Cyan
    Write-Host "  3. Set permanently in system:" -ForegroundColor Gray
    Write-Host "     [Environment]::SetEnvironmentVariable('ANDROID_HOME', 'D:\path\to\Sdk', 'User')" -ForegroundColor Cyan
}

# Find Java/JDK
$JavaHome = Find-JavaHome
if ($JavaHome) {
    Write-Host "[OK] Java found: $JavaHome" -ForegroundColor Green
    
    # Set JAVA_HOME if not set
    if (-not $env:JAVA_HOME) {
        $env:JAVA_HOME = $JavaHome
        Write-Host "     Set JAVA_HOME=$JavaHome" -ForegroundColor Gray
    }
    
    # Add Java to PATH
    $javaBin = "$JavaHome\bin"
    if ($env:Path -notlike "*$javaBin*") {
        $env:Path = "$javaBin;$env:Path"
        Write-Host "     Added Java to PATH" -ForegroundColor Gray
    }
} else {
    Write-Host "[ERROR] Java/JDK not found!" -ForegroundColor Red
    Write-Host "Options:" -ForegroundColor Yellow
    Write-Host "  1. Use Android Studio bundled JDK (recommended):" -ForegroundColor Gray
    Write-Host "     Usually at: C:\Program Files\Android\Android Studio\jbr" -ForegroundColor Cyan
    Write-Host "  2. Install JDK 17+ from:" -ForegroundColor Gray
    Write-Host "     https://adoptium.net/ or https://www.oracle.com/java/" -ForegroundColor Cyan
    Write-Host "  3. Set JAVA_HOME manually:" -ForegroundColor Gray
    Write-Host "     `$env:JAVA_HOME = 'C:\path\to\jdk'" -ForegroundColor Cyan
}

# Find AVD directory
$AVDDir = Find-AVDDirectory
if ($AVDDir) {
    # Look for .ini files (real AVD names, not folders)
    $avdIniFiles = Get-ChildItem "$AVDDir\*.ini" -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -notmatch "\.avd\.ini$" -and $_.Name -match "\.ini$" }
    if ($avdIniFiles) {
        Write-Host "[OK] AVD directory: $AVDDir" -ForegroundColor Green
        Write-Host "     Available AVDs:" -ForegroundColor Gray
        foreach ($avd in $avdIniFiles) {
            Write-Host "       - $($avd.BaseName)" -ForegroundColor Gray
        }
    } else {
        # Fallback: check folders
        $avdFolders = Get-ChildItem "$AVDDir\*.avd" -Directory -ErrorAction SilentlyContinue
        if ($avdFolders) {
            Write-Host "[OK] AVD directory: $AVDDir" -ForegroundColor Green
            Write-Host "     Available AVDs:" -ForegroundColor Gray
            foreach ($avd in $avdFolders) {
                $avdName = $avd.Name -replace '\.avd$', ''
                Write-Host "       - $avdName" -ForegroundColor Gray
            }
        } else {
            Write-Host "[WARN] AVD directory exists but no AVDs found" -ForegroundColor Yellow
            Write-Host "     Create AVD in Android Studio: Tools > Device Manager" -ForegroundColor Gray
        }
    }
} else {
    Write-Host "[WARN] AVD directory not found" -ForegroundColor Yellow
}

Write-Host ""

# Add Flutter to PATH
if ($FoundFlutter) {
    if ($Permanent) {
        Write-Host "Adding Flutter to system PATH permanently..." -ForegroundColor Yellow
        
        $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
        
        if ($currentPath -notlike "*$FoundFlutter*") {
            [Environment]::SetEnvironmentVariable("Path", "$currentPath;$FoundFlutter", "User")
            Write-Host "Flutter added to user PATH. Restart terminal to apply." -ForegroundColor Green
        } else {
            Write-Host "Flutter already in PATH." -ForegroundColor Green
        }
    } else {
        # Add to current session only
        if ($env:Path -notlike "*$FoundFlutter*") {
            $env:Path = "$FoundFlutter;$env:Path"
            Write-Host "Flutter added to current session PATH." -ForegroundColor Green
        } else {
            Write-Host "Flutter already in session PATH." -ForegroundColor Green
        }
    }
    
    # Add emulator to PATH if Android SDK found
    if ($AndroidSDK) {
        $emulatorPath = "$AndroidSDK\emulator"
        $platformToolsPath = "$AndroidSDK\platform-tools"
        
        if ($env:Path -notlike "*$emulatorPath*") {
            $env:Path = "$emulatorPath;$platformToolsPath;$env:Path"
            Write-Host "Android tools added to session PATH." -ForegroundColor Green
        }
    }
    
    # Verify
    Write-Host ""
    Write-Host "Flutter version:" -ForegroundColor Cyan
    flutter --version
}

# Diagnose mode - show detailed info
if ($Diagnose) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Detailed Diagnostics" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Environment Variables:" -ForegroundColor Yellow
    Write-Host "  ANDROID_HOME: $env:ANDROID_HOME" -ForegroundColor Gray
    Write-Host "  ANDROID_SDK_ROOT: $env:ANDROID_SDK_ROOT" -ForegroundColor Gray
    Write-Host "  ANDROID_AVD_HOME: $env:ANDROID_AVD_HOME" -ForegroundColor Gray
    Write-Host "  JAVA_HOME: $env:JAVA_HOME" -ForegroundColor Gray
    Write-Host ""
    
    # Search for Android SDK on all drives if not found
    if (-not $AndroidSDK) {
        Write-Host "Searching for Android SDK on all drives..." -ForegroundColor Yellow
        $drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Free -gt 0 }
        $foundPaths = @()
        
        foreach ($drive in $drives) {
            $searchPaths = @(
                "$($drive.Root)Android\Sdk",
                "$($drive.Root)Android\android-sdk",
                "$($drive.Root)sdk\android",
                "$($drive.Root)dev\android-sdk",
                "$($drive.Root)Program Files\Android\Sdk",
                "$($drive.Root)Program Files (x86)\Android\android-sdk"
            )
            
            foreach ($path in $searchPaths) {
                if (Test-Path $path) {
                    $foundPaths += $path
                    Write-Host "  Found: $path" -ForegroundColor Green
                }
            }
        }
        
        # Also search in user folders
        $userSearchPaths = @(
            "$env:LOCALAPPDATA\Android\Sdk",
            "$env:USERPROFILE\Android\Sdk",
            "$env:USERPROFILE\AppData\Local\Android\Sdk"
        )
        foreach ($path in $userSearchPaths) {
            if ((Test-Path $path) -and ($foundPaths -notcontains $path)) {
                $foundPaths += $path
                Write-Host "  Found: $path" -ForegroundColor Green
            }
        }
        
        if ($foundPaths.Count -eq 0) {
            Write-Host "  No Android SDK found on any drive" -ForegroundColor Red
        } else {
            Write-Host ""
            Write-Host "To use found SDK, run:" -ForegroundColor Yellow
            Write-Host "  .\setup-env.ps1 -AndroidSDKPath '$($foundPaths[0])'" -ForegroundColor Cyan
        }
        Write-Host ""
    }
    
    if ($AndroidSDK) {
        Write-Host "Android SDK Contents:" -ForegroundColor Yellow
        Get-ChildItem $AndroidSDK -Directory | ForEach-Object { Write-Host "  $($_.Name)" -ForegroundColor Gray }
        Write-Host ""
        
        # Check emulator executable
        $emulatorExe = "$AndroidSDK\emulator\emulator.exe"
        if (Test-Path $emulatorExe) {
            Write-Host "Emulator executable: OK" -ForegroundColor Green
            Write-Host "Running: emulator -list-avds" -ForegroundColor Yellow
            & $emulatorExe -list-avds
        } else {
            Write-Host "Emulator executable: NOT FOUND" -ForegroundColor Red
        }
    }
    
    Write-Host ""
    Write-Host "Flutter Doctor:" -ForegroundColor Yellow
    flutter doctor
}
