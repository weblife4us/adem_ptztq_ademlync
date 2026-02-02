@echo off
REM ============================================
REM Run Application on Emulator
REM ============================================

set PATH=C:\flutter\bin;%PATH%

cd /d d:\cursor\ademlync\ademlync

echo ========================================
echo Running AdEMLync Application
echo ========================================
echo.

REM Check for Android emulator first
call flutter devices 2>nul | findstr /C:"emulator-" >nul
if %errorlevel%==0 (
    echo Found Android emulator, starting app...
    echo.
    call flutter run -d emulator-5554
    pause
    exit /b 0
)

REM No emulator, show devices and run on default
echo Connected devices:
call flutter devices
echo.
echo Starting app on default device...
call flutter run

pause
