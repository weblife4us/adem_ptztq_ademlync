# ============================================
# Build APK
# ============================================

param(
    [switch]$Release,
    [switch]$Bundle,
    [switch]$Split,
    [switch]$Open
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

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectDir = Split-Path -Parent $scriptDir
Set-Location $projectDir

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Building Android Package" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$args = @("build")

if ($Bundle) {
    $args += "appbundle"
    Write-Host "Building: App Bundle (.aab)" -ForegroundColor Yellow
} else {
    $args += "apk"
    Write-Host "Building: APK" -ForegroundColor Yellow
}

if ($Release) {
    $args += "--release"
    Write-Host "Mode: RELEASE" -ForegroundColor Magenta
} else {
    $args += "--debug"
    Write-Host "Mode: DEBUG" -ForegroundColor Magenta
}

if ($Split -and -not $Bundle) {
    $args += "--split-per-abi"
    Write-Host "Split: Per ABI" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Running: flutter $($args -join ' ')" -ForegroundColor Gray
Write-Host ""

& flutter @args

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Build complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

$outputPath = "$projectDir\build\app\outputs"
if ($Bundle) {
    $outputPath += "\bundle"
} else {
    $outputPath += "\flutter-apk"
}

Write-Host ""
Write-Host "Output: $outputPath" -ForegroundColor Cyan

if ($Open) {
    explorer $outputPath
}
