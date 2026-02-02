# ============================================
# Build APK
# ============================================

param(
    [switch]$Release,
    [switch]$Bundle,
    [switch]$Split,
    [switch]$Open
)

# Add Flutter to PATH
$env:Path = "C:\flutter\bin;$env:Path"

Set-Location "d:\cursor\ademlync\ademlync"

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

$outputPath = "d:\cursor\ademlync\ademlync\build\app\outputs"
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
