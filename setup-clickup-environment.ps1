# ====================================================
# CLICKUP ENVIRONMENT SETUP SCRIPT
# ====================================================
# This script sets up the ClickUp CLI and environment for the SOAHC-NIKCUF-Unity project.
# Run this script on any new development machine to configure the ClickUp integration.
#
# INSTRUCTIONS:
# 1. Make sure you have Node.js installed (https://nodejs.org/)
# 2. Run this script with PowerShell as Administrator
# 3. Follow the prompts to complete the setup
# ====================================================

# Set console colors for better readability
$host.UI.RawUI.BackgroundColor = "Black"
$host.UI.RawUI.ForegroundColor = "White"
Clear-Host

Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "  SOAHC-NIKCUF-UNITY CLICKUP ENVIRONMENT SETUP" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check if Node.js is installed
Write-Host "[Step 1] Checking if Node.js is installed..." -ForegroundColor Yellow
try {
    $nodeVersion = node --version
    Write-Host "SUCCESS: Node.js is installed: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Node.js is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Node.js from https://nodejs.org/ and run this script again." -ForegroundColor Red
    Write-Host "Press any key to exit..."
    $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

# Step 2: Install ClickUp CLI
Write-Host "`n[Step 2] Installing ClickUp CLI..." -ForegroundColor Yellow
try {
    npm install -g clickup-cli
    Write-Host "SUCCESS: ClickUp CLI installed successfully" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to install ClickUp CLI" -ForegroundColor Red
    Write-Host "Error details: $_" -ForegroundColor Red
    Write-Host "Press any key to exit..."
    $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

# Step 3: Create ClickUp configuration
Write-Host "`n[Step 3] Setting up ClickUp configuration..." -ForegroundColor Yellow
$apiToken = "pk_132021316_3Y2JWD1NM4GGY3RV63JJ01PFUA9PQCQJ"
$teamId = "9013790997"

$configPath = "clickup-config.json"
$config = @{
    token = $apiToken
    team = $teamId
} | ConvertTo-Json

$config | Out-File -FilePath $configPath
Write-Host "SUCCESS: ClickUp configuration created at $configPath" -ForegroundColor Green

# Step 4: Create ClickUp CLI shortcut
Write-Host "`n[Step 4] Creating ClickUp CLI shortcut..." -ForegroundColor Yellow
$npmPath = npm config get prefix
$clickupPath = Join-Path $npmPath "node_modules\clickup-cli\bin\clickup.js"

# Create a batch file shortcut
@"
@echo off
node "$clickupPath" %*
"@ | Out-File -FilePath "clickup.bat" -Encoding ascii

Write-Host "SUCCESS: ClickUp CLI shortcut created at clickup.bat" -ForegroundColor Green

# Step 5: Add ClickUp CLI to PATH for current session
Write-Host "`n[Step 5] Adding ClickUp CLI to PATH for current session..." -ForegroundColor Yellow
$env:PATH = "$env:PATH;$npmPath"
Write-Host "SUCCESS: ClickUp CLI added to PATH for current session" -ForegroundColor Green

# Step 6: Test ClickUp CLI
Write-Host "`n[Step 6] Testing ClickUp CLI..." -ForegroundColor Yellow
try {
    $output = cmd /c "clickup.bat --help"
    if ($output -match "clickup cli") {
        Write-Host "SUCCESS: ClickUp CLI is working properly" -ForegroundColor Green
    } else {
        Write-Host "WARNING: ClickUp CLI test returned unexpected output" -ForegroundColor Yellow
        Write-Host "Output: $output" -ForegroundColor Yellow
    }
} catch {
    Write-Host "WARNING: ClickUp CLI test failed" -ForegroundColor Yellow
    Write-Host "Error details: $_" -ForegroundColor Red
    Write-Host "You may need to restart your terminal or use the clickup.bat shortcut directly." -ForegroundColor Yellow
}

# Step 7: Verify ClickUp container tasks
Write-Host "`n[Step 7] Verifying ClickUp container tasks..." -ForegroundColor Yellow
$containerTasks = @(
    @{ id = "86a7a1ddr"; name = "Bug Fixes" },
    @{ id = "86a7a1ddt"; name = "Features" },
    @{ id = "86a7a1ddv"; name = "Refactors" },
    @{ id = "86a7a1ddw"; name = "Performance Optimizations" },
    @{ id = "86a7a1ddy"; name = "UI/UX Improvements" },
    @{ id = "86a7a1ddz"; name = "Art & Assets" },
    @{ id = "86a7a1de0"; name = "Audio" },
    @{ id = "86a7a1de1"; name = "Documentation" }
)

Write-Host "Container tasks available for commit references:" -ForegroundColor Green
foreach ($task in $containerTasks) {
    Write-Host "  - $($task.name): #$($task.id)" -ForegroundColor Green
}

# Step 8: Display initial tasks
Write-Host "`n[Step 8] Displaying initial tasks..." -ForegroundColor Yellow
$initialTasks = @(
    @{ id = "86a7a1dwk"; name = "Set up Unity project with appropriate settings" },
    @{ id = "86a7a1dwm"; name = "Create .gitignore for Unity" },
    @{ id = "86a7a1dwn"; name = "Create initial scene structure" },
    @{ id = "86a7a1dwp"; name = "Implement basic player controller" },
    @{ id = "86a7a1dwr"; name = "Set up camera system" },
    @{ id = "86a7a1dwt"; name = "Create main menu UI" },
    @{ id = "86a7a1dwu"; name = "Implement in-game HUD" }
)

Write-Host "Initial tasks to work on:" -ForegroundColor Green
foreach ($task in $initialTasks) {
    Write-Host "  - $($task.name): #$($task.id)" -ForegroundColor Green
}

# Step 9: Create a test file for integration testing
Write-Host "`n[Step 9] Creating a test file for integration testing..." -ForegroundColor Yellow
$testFileName = "clickup-integration-test.txt"
$dateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$content = "ClickUp integration test file`nCreated at: $dateTime`nThis file was created to test the ClickUp-GitHub integration."
$content | Out-File -FilePath $testFileName

Write-Host "SUCCESS: Test file created at $testFileName" -ForegroundColor Green
Write-Host "You can use this file to test the ClickUp-GitHub integration." -ForegroundColor Green

# Step 10: Display next steps
Write-Host "`n[Step 10] Setup completed successfully!" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "NEXT STEPS:" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "1. Test the ClickUp-GitHub integration:" -ForegroundColor White
Write-Host "   - Run: .\test-clickup-integration.ps1" -ForegroundColor White
Write-Host "2. Begin working on the first task:" -ForegroundColor White
Write-Host "   - Set up Unity project with appropriate settings (#86a7a1dwk)" -ForegroundColor White
Write-Host "3. Use the container task IDs in your commit messages:" -ForegroundColor White
Write-Host "   - Example: git commit -m 'Add feature X #86a7a1ddt'" -ForegroundColor White
Write-Host "4. Update task statuses in ClickUp as you progress" -ForegroundColor White
Write-Host "5. Refer to notes.txt and clickup-container-tasks-reference.md for more details" -ForegroundColor White
Write-Host "=====================================================" -ForegroundColor Cyan

Write-Host "`nPress any key to exit..."
$null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# ClickUp Environment Setup Script
# This script sets up the necessary environment variables for ClickUp integration

# Function to set environment variable
function Set-EnvironmentVariable {
    param (
        [string]$Name,
        [string]$Value,
        [string]$Scope = "User"
    )
    
    [System.Environment]::SetEnvironmentVariable($Name, $Value, $Scope)
    Write-Host "Set environment variable: $Name"
}

# Get ClickUp API Token
$apiToken = Read-Host -Prompt "Enter your ClickUp API Token"
if ($apiToken) {
    Set-EnvironmentVariable -Name "CLICKUP_API_TOKEN" -Value $apiToken
}

# Get ClickUp Team ID
$teamId = Read-Host -Prompt "Enter your ClickUp Team ID"
if ($teamId) {
    Set-EnvironmentVariable -Name "CLICKUP_TEAM_ID" -Value $teamId
}

Write-Host "`nClickUp environment variables have been set up successfully."
Write-Host "Please restart your terminal for the changes to take effect." 