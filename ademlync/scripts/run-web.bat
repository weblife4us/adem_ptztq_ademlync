@echo off
REM ============================================
REM Run Application in Chrome
REM ============================================

set PATH=C:\flutter\bin;%PATH%

cd /d d:\cursor\ademlync\ademlync

echo ========================================
echo Running AdEMLync in Chrome
echo ========================================
echo.

call flutter run -d chrome

pause
