@echo off
echo ===================================================
echo  SOAHC-NIKCUF-UNITY CLICKUP SETUP LAUNCHER
echo ===================================================
echo.
echo This will launch the ClickUp environment setup script.
echo.
echo IMPORTANT: This script requires administrator privileges.
echo.
pause

powershell -ExecutionPolicy Bypass -Command "Start-Process powershell -ArgumentList '-ExecutionPolicy Bypass -File \"%~dp0setup-clickup-environment.ps1\"' -Verb RunAs"

echo.
echo If a UAC prompt appeared, please click "Yes" to continue.
echo.
pause 