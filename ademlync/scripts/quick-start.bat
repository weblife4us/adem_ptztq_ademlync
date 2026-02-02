@echo off
REM ============================================
REM Quick Start - Emulator + App
REM ============================================

set PATH=C:\flutter\bin;%PATH%

cd /d d:\cursor\ademlync\ademlync

echo ========================================
echo AdEMLync Quick Start
echo ========================================
echo.

echo [1/4] Checking Flutter...
call flutter --version
echo.

echo [2/4] Installing dependencies...
call flutter pub get
echo.

echo [3/4] Starting emulator...
call flutter emulators --launch Pixel_9_Pro_XL

echo.
echo Waiting for emulator (40 seconds)...
timeout /t 40 /nobreak

echo.
echo [4/4] Running app...
call flutter run

pause
