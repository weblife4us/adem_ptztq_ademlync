# ============================================
# Generate Code (build_runner)
# ============================================

param(
    [switch]$Watch,
    [switch]$Delete
)

# Add Flutter to PATH
$env:Path = "C:\flutter\bin;$env:Path"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Code Generation (build_runner)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Set-Location "d:\cursor\ademlync\packages\ademlync_cloud"

$args = @("pub", "run", "build_runner")

if ($Watch) {
    $args += "watch"
    Write-Host "Mode: WATCH (continuous)" -ForegroundColor Yellow
} else {
    $args += "build"
    Write-Host "Mode: BUILD (one-time)" -ForegroundColor Yellow
}

if ($Delete) {
    $args += "--delete-conflicting-outputs"
    Write-Host "Delete conflicting outputs: YES" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Running: flutter $($args -join ' ')" -ForegroundColor Gray
Write-Host ""

& flutter @args

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Code generation complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
