@echo off
echo ===================================================
echo  DIRECT CLICKUP API ACCESS
echo ===================================================
echo.
echo This will launch the direct ClickUp API access script.
echo Use this if you're having trouble with the ClickUp CLI.
echo.
echo IMPORTANT: This script requires PowerShell.
echo.
pause

powershell -ExecutionPolicy Bypass -File "%~dp0direct-clickup-api.ps1"

echo.
echo Script completed.
echo.
pause 