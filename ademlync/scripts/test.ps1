# ============================================
# Run Tests
# ============================================

param(
    [switch]$Coverage,
    [string]$Filter
)

# Add Flutter to PATH
$env:Path = "C:\flutter\bin;$env:Path"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Running Tests" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$rootDir = "d:\cursor\ademlync"

# Test main app
Write-Host "[1/3] Testing main app..." -ForegroundColor Yellow
Set-Location "$rootDir\ademlync"

$args = @("test")
if ($Coverage) { $args += "--coverage" }
if ($Filter) { $args += "--name", $Filter }

& flutter @args
Write-Host ""

# Test device package
Write-Host "[2/3] Testing ademlync_device..." -ForegroundColor Yellow
Set-Location "$rootDir\packages\ademlync_device"
& flutter @args
Write-Host ""

# Test cloud package
Write-Host "[3/3] Testing ademlync_cloud..." -ForegroundColor Yellow
Set-Location "$rootDir\packages\ademlync_cloud"
& flutter @args

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Tests complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
