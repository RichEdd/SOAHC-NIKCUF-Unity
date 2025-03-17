# ClickUp CLI Setup Script
# This script sets up the ClickUp CLI with proper configuration

# Function to check if Node.js is installed
function Test-NodeJS {
    try {
        $null = Get-Command node -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# Function to install Node.js if not present
function Install-NodeJS {
    Write-Host "Node.js is not installed. Installing Node.js..."
    # You can add Node.js installation logic here if needed
    Write-Host "Please install Node.js from https://nodejs.org/"
    exit 1
}

# Function to install ClickUp CLI
function Install-ClickUpCLI {
    Write-Host "Installing ClickUp CLI..."
    npm install -g clickup-cli
}

# Function to create ClickUp configuration
function Set-ClickUpConfig {
    param (
        [string]$Token,
        [string]$Team
    )
    
    # Create temporary file
    $tempFile = Join-Path $env:TEMP "clickup-config.tmp"
    $configContent = @"
token: $Token
team: $Team
"@
    
    # Write to temporary file first
    $configContent | Out-File -FilePath $tempFile -Encoding UTF8 -Force
    
    # Create the target directory if it doesn't exist
    $targetDir = Join-Path $env:USERPROFILE ".clickup"
    if (-not (Test-Path $targetDir)) {
        New-Item -Path $targetDir -ItemType Directory -Force | Out-Null
    }
    
    # Move the file to the correct location
    $targetFile = Join-Path $targetDir "config.yml"
    Move-Item -Path $tempFile -Destination $targetFile -Force
    
    Write-Host "ClickUp configuration created at: $targetFile"
}

# Main setup process
Write-Host "Starting ClickUp CLI setup..."

# Check for Node.js
if (-not (Test-NodeJS)) {
    Install-NodeJS
}

# Install ClickUp CLI
Install-ClickUpCLI

# Use provided credentials
$token = "pk_132021316_3Y2JWD1NM4GGY3RV63JJ01PFUA9PQCQJ"
$team = "9013790997"

# Create configuration
Set-ClickUpConfig -Token $token -Team $team

Write-Host "`nClickUp CLI setup completed successfully!"
Write-Host "Please restart your terminal for the changes to take effect." 