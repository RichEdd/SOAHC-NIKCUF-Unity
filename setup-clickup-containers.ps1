# Setup ClickUp Container Tasks Script
# This script helps you set up container tasks in ClickUp for your Unity project

Write-Host "ClickUp Container Tasks Setup" -ForegroundColor Cyan
Write-Host "============================" -ForegroundColor Cyan
Write-Host ""

# Check if the ClickUp CLI is available
$clickupCmd = "C:\Users\Coder\AppData\Roaming\npm\clickup.cmd"
if (-not (Test-Path $clickupCmd)) {
    Write-Host "ERROR: ClickUp CLI not found at $clickupCmd" -ForegroundColor Red
    Write-Host "Please make sure you have installed the ClickUp CLI using 'npm install -g clickup-cli'" -ForegroundColor Red
    exit
}

# Step 1: Set up ClickUp configuration
Write-Host "[Step 1] Setting up ClickUp configuration" -ForegroundColor Yellow
Write-Host "You need to provide your ClickUp API token and Team ID." -ForegroundColor Yellow
Write-Host "You can find your API token at: https://app.clickup.com/settings/apps" -ForegroundColor Yellow
Write-Host "You can find your Team ID in the URL when you're in your workspace: https://app.clickup.com/t/TEAM_ID/..." -ForegroundColor Yellow

Write-Host "`nEnter your ClickUp API token:" -ForegroundColor Cyan
$apiToken = Read-Host

Write-Host "Enter your ClickUp Team ID:" -ForegroundColor Cyan
$teamId = Read-Host

# Update the config file
$configPath = "clickup-config.json"
$config = @{
    token = $apiToken
    team = $teamId
}
$config | ConvertTo-Json | Out-File -FilePath $configPath

Write-Host "Configuration saved to $configPath" -ForegroundColor Green

# Step 2: Create a new list for container tasks
Write-Host "`n[Step 2] Creating a new list for container tasks" -ForegroundColor Yellow
Write-Host "Enter the Space ID where you want to create the list:" -ForegroundColor Cyan
$spaceId = Read-Host

# Create container tasks
$containerTasks = @(
    @{
        name = "Bug Fixes"
        description = "Container for all bug fix commits. Use this task ID when committing code that fixes bugs, resolves issues, or addresses unexpected behavior."
    },
    @{
        name = "Features"
        description = "Container for all new feature implementations. Use this task ID when committing code that adds new functionality, systems, or capabilities to the game."
    },
    @{
        name = "Refactors"
        description = "Container for code refactoring and improvements. Use this task ID when committing code that improves structure, readability, or maintainability without changing functionality."
    },
    @{
        name = "Performance Optimizations"
        description = "Container for performance-related changes. Use this task ID when committing code that improves game performance, reduces memory usage, or optimizes resource loading."
    },
    @{
        name = "UI/UX Improvements"
        description = "Container for user interface and experience changes. Use this task ID when committing code that enhances the game's UI, menus, HUD, or overall user experience."
    },
    @{
        name = "Art & Assets"
        description = "Container for art-related commits. Use this task ID when committing new or updated art assets, models, textures, or visual effects."
    },
    @{
        name = "Audio"
        description = "Container for audio-related commits. Use this task ID when committing new or updated sound effects, music, or audio systems."
    },
    @{
        name = "Documentation"
        description = "Container for documentation updates. Use this task ID when committing changes to documentation, comments, or README files."
    }
)

# Create the list
Write-Host "`nCreating a new list 'Development Categories'..." -ForegroundColor Yellow
$listName = "Development Categories"
$createListCmd = "$clickupCmd create -c $configPath -s $spaceId -n `"$listName`" -d `"Container tasks for organizing Unity project commits`""
Write-Host "Running: $createListCmd" -ForegroundColor Gray
$listResult = Invoke-Expression $createListCmd

if ($listResult -match "id: (\w+)") {
    $listId = $matches[1]
    Write-Host "List created with ID: $listId" -ForegroundColor Green

    # Create tasks in the list
    Write-Host "`n[Step 3] Creating container tasks" -ForegroundColor Yellow
    foreach ($task in $containerTasks) {
        Write-Host "Creating task: $($task.name)..." -ForegroundColor Yellow
        $createTaskCmd = "$clickupCmd create -c $configPath -l $listId -n `"$($task.name)`" -d `"$($task.description)`""
        Write-Host "Running: $createTaskCmd" -ForegroundColor Gray
        $taskResult = Invoke-Expression $createTaskCmd
        
        if ($taskResult -match "id: (\w+)") {
            $taskId = $matches[1]
            Write-Host "Task created with ID: $taskId" -ForegroundColor Green
            Write-Host "Use this in commit messages: #$taskId" -ForegroundColor Green
        } else {
            Write-Host "Failed to create task: $($task.name)" -ForegroundColor Red
            Write-Host "Error: $taskResult" -ForegroundColor Red
        }
    }
} else {
    Write-Host "Failed to create list" -ForegroundColor Red
    Write-Host "Error: $listResult" -ForegroundColor Red
}

Write-Host "`nSetup completed!" -ForegroundColor Cyan
Write-Host "Remember to use the task IDs in your commit messages with the # symbol." -ForegroundColor Cyan
Write-Host "Example: git commit -m 'Fix player collision detection #TASK_ID'" -ForegroundColor Cyan 