@echo off
REM ============================================
REM Run Android Emulator
REM ============================================

set PATH=C:\flutter\bin;%PATH%

echo ========================================
echo Android Emulator Manager
echo ========================================
echo.

REM Check if emulator already running
call flutter devices 2>nul | findstr /C:"emulator-" >nul
if %errorlevel%==0 (
    echo Emulator already running!
    echo.
    call flutter devices
    echo.
    pause
    exit /b 0
)

echo Starting emulator...
call flutter emulators --launch Pixel_9_Pro_XL

echo.
echo Waiting for emulator to boot (40 seconds)...
timeout /t 40 /nobreak

echo.
echo Connected devices:
call flutter devices

pause
