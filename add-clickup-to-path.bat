@echo off
echo Adding ClickUp CLI to PATH environment variable...

set CLICKUP_PATH=C:\Users\Coder\AppData\Roaming\npm

:: Check if the path exists
if not exist "%CLICKUP_PATH%" (
    echo ERROR: ClickUp CLI path not found at %CLICKUP_PATH%
    echo Please make sure you have installed the ClickUp CLI using 'npm install -g clickup-cli'
    exit /b 1
)

:: Add to PATH for current session
set PATH=%PATH%;%CLICKUP_PATH%
echo Added %CLICKUP_PATH% to PATH for current session.

:: Check if clickup command works
where clickup >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo SUCCESS: ClickUp CLI is now available in your PATH.
    echo You can use 'clickup' command in this terminal session.
) else (
    echo WARNING: ClickUp CLI was added to PATH but the command is not recognized.
    echo You may need to restart your terminal or use the full path: %CLICKUP_PATH%\clickup.cmd
)

:: Create a shortcut to the ClickUp CLI
echo @echo off > clickup.bat
echo "%CLICKUP_PATH%\clickup.cmd" %%* >> clickup.bat
echo Created clickup.bat shortcut in the current directory.

echo.
echo To make this change permanent, you need to add the following path to your system PATH:
echo %CLICKUP_PATH%
echo.
echo You can do this by:
echo 1. Right-click on 'This PC' or 'My Computer' and select 'Properties'
echo 2. Click on 'Advanced system settings'
echo 3. Click on 'Environment Variables'
echo 4. Under 'System variables', find and select 'Path', then click 'Edit'
echo 5. Click 'New' and add: %CLICKUP_PATH%
echo 6. Click 'OK' on all dialogs to save the changes
echo.
echo Alternatively, you can use the clickup.bat shortcut created in this directory.

pause 