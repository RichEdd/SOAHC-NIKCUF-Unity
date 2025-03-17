# Manual ClickUp CLI Setup Guide

This guide provides explicit, step-by-step instructions for setting up the ClickUp CLI on a Windows machine.

## Prerequisites

1. **Node.js Installation**
   - Download Node.js from: https://nodejs.org/en/download/ (LTS version recommended)
   - Run the installer and follow the prompts
   - Make sure to check the option to "Add to PATH" during installation
   - Verify installation by opening a new Command Prompt and typing:
     ```
     node --version
     npm --version
     ```
   - Both commands should display version numbers if installed correctly

## Step 1: Install ClickUp CLI

1. **Open Command Prompt as Administrator**
   - Press Windows key
   - Type "cmd"
   - Right-click on "Command Prompt" and select "Run as administrator"
   - Click "Yes" on the UAC prompt

2. **Install ClickUp CLI globally**
   - In the Command Prompt, type:
     ```
     npm install -g clickup-cli
     ```
   - Wait for the installation to complete (this may take a few minutes)
   - You should see a success message when it's done

3. **Verify Installation**
   - In the same Command Prompt, type:
     ```
     npm list -g clickup-cli
     ```
   - You should see the installed version of clickup-cli

## Step 2: Create Configuration File

1. **Create a directory for ClickUp configuration**
   - In Command Prompt, navigate to your project directory:
     ```
     cd path\to\your\project
     ```
   - Or create a new directory if needed:
     ```
     mkdir ClickUp
     cd ClickUp
     ```

2. **Create the configuration file**
   - In Command Prompt, type:
     ```
     notepad clickup-config.json
     ```
   - When Notepad opens, paste the following content:
     ```json
     {
       "token": "pk_132021316_3Y2JWD1NM4GGY3RV63JJ01PFUA9PQCQJ",
       "team": "9013790997"
     }
     ```
   - Save the file and close Notepad

## Step 3: Create a ClickUp CLI Shortcut

1. **Find the path to the ClickUp CLI**
   - In Command Prompt, type:
     ```
     where clickup
     ```
   - If that doesn't work, try:
     ```
     npm config get prefix
     ```
   - This will show you the npm installation directory (e.g., C:\Users\username\AppData\Roaming\npm)
   - The ClickUp CLI should be in the node_modules\clickup-cli\bin directory under this path

2. **Create a batch file shortcut**
   - In Command Prompt, type:
     ```
     notepad clickup.bat
     ```
   - When Notepad opens, paste the following (replace the path with your actual npm path):
     ```batch
     @echo off
     node "C:\Users\username\AppData\Roaming\npm\node_modules\clickup-cli\bin\clickup.js" %*
     ```
   - Save the file and close Notepad

## Step 4: Test the ClickUp CLI

1. **Run a basic ClickUp command**
   - In Command Prompt, type:
     ```
     clickup.bat --help
     ```
   - You should see the ClickUp CLI help information

2. **Test with your configuration**
   - In Command Prompt, type:
     ```
     clickup.bat --config clickup-config.json list
     ```
   - This should list your ClickUp workspaces

## Troubleshooting

If you encounter issues:

1. **Node.js not found**
   - Make sure Node.js is installed and added to your PATH
   - Try restarting your computer after installation

2. **Permission errors during installation**
   - Make sure you're running Command Prompt as Administrator

3. **ClickUp CLI not found**
   - Try installing with a specific version:
     ```
     npm install -g clickup-cli@1.0.0
     ```

4. **Configuration issues**
   - Verify your API token is correct
   - Make sure the JSON file is properly formatted

5. **Path issues**
   - If the batch file doesn't work, try using the full path to the clickup.js file:
     ```
     node "C:\full\path\to\npm\node_modules\clickup-cli\bin\clickup.js" --help
     ```

## Alternative: Direct API Access

If the CLI continues to be problematic, you can use direct API calls with PowerShell:

```powershell
$apiToken = "pk_132021316_3Y2JWD1NM4GGY3RV63JJ01PFUA9PQCQJ"
$teamId = "9013790997"

$headers = @{
    "Authorization" = $apiToken
    "Content-Type" = "application/json"
}

# Get team information
$response = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/team/$teamId" -Headers $headers -Method Get

# Display team info
$response | ConvertTo-Json
```

Save this as `test-clickup-api.ps1` and run it with PowerShell to test direct API access. 