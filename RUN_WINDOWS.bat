@echo off
cd /d "%~dp0"
flutter pub get
if errorlevel 1 pause & exit /b 1
flutter run
pause
