@echo off
setlocal
cd /d "%~dp0"

echo =====================================================
echo  ALO SOLAR ENERGY - ONE CLICK ANDROID REPAIR + BUILD
echo =====================================================
where flutter >nul 2>nul
if errorlevel 1 (
  echo.
  echo Flutter is not available in PATH.
  echo Add the Flutter bin folder to Windows PATH, close Android Studio,
  echo reopen it, then run this file again.
  echo Example: C:\flutter\bin
  pause
  exit /b 1
)

echo.
echo [1/5] Flutter version
flutter --version
if errorlevel 1 goto :fail

echo.
echo [2/5] Completing/repairing Android project files
flutter create . --platforms=android --org com.alosolarenergy
if errorlevel 1 goto :fail

echo.
echo [3/5] Downloading Flutter packages
flutter pub get
if errorlevel 1 goto :fail

echo.
echo [4/5] Checking source code
flutter analyze
if errorlevel 1 (
  echo.
  echo Analyze returned warnings/errors. Build will still be attempted.
)

echo.
echo [5/5] Building APK
flutter build apk --debug
if errorlevel 1 goto :fail

echo.
echo =====================================================
echo SUCCESS - APK CREATED
echo build\app\outputs\flutter-apk\app-debug.apk
echo =====================================================
start "" "%~dp0build\app\outputs\flutter-apk"
pause
exit /b 0

:fail
echo.
echo =====================================================
echo BUILD FAILED
ECHO Send a screenshot of the LAST red lines only.
echo =====================================================
pause
exit /b 1
