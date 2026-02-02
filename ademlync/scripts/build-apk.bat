@echo off
REM ============================================
REM Build Release APK
REM ============================================

set PATH=C:\flutter\bin;%PATH%

cd /d d:\cursor\ademlync\ademlync

echo ========================================
echo Building Release APK
echo ========================================
echo.

call flutter build apk --release

echo.
echo ========================================
echo Build complete!
echo ========================================
echo.
echo APK location:
echo d:\cursor\ademlync\ademlync\build\app\outputs\flutter-apk\
echo.

explorer d:\cursor\ademlync\ademlync\build\app\outputs\flutter-apk

pause
