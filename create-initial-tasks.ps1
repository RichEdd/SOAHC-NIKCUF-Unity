# Create Initial ClickUp Tasks Script
# This script creates initial tasks in ClickUp for the Unity project

$apiToken = "pk_132021316_3Y2JWD1NM4GGY3RV63JJ01PFUA9PQCQJ"
$listId = "901308586205" # The Development Categories list

Write-Host "Creating Initial ClickUp Tasks" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan
Write-Host ""

# Create auth header
$headers = @{
    Authorization = $apiToken
    "Content-Type" = "application/json"
}

# Initial tasks to create
$initialTasks = @(
    # Project Setup Tasks
    @{
        name = "Set up Unity project with appropriate settings"
        description = "Create a new Unity project with version 2022.3 LTS or newer. Configure for 3D development and set up appropriate project settings."
        status = "Backlog"
        tags = @("setup", "unity")
        priority = 1
        container = "86a7a1ddt" # Features
    },
    @{
        name = "Create .gitignore for Unity"
        description = "Set up a proper .gitignore file for Unity to avoid committing unnecessary files."
        status = "Backlog"
        tags = @("setup", "git")
        priority = 1
        container = "86a7a1ddt" # Features
    },
    @{
        name = "Create initial scene structure"
        description = "Set up the basic scene structure for the game, including main menu, game scene, and settings scene."
        status = "Backlog"
        tags = @("setup", "unity")
        priority = 2
        container = "86a7a1ddt" # Features
    },
    
    # Core Gameplay Tasks
    @{
        name = "Implement basic player controller"
        description = "Create a player controller with basic movement, jumping, and interaction capabilities."
        status = "Backlog"
        tags = @("gameplay", "player")
        priority = 2
        container = "86a7a1ddt" # Features
    },
    @{
        name = "Set up camera system"
        description = "Implement a camera system that follows the player and handles different game states."
        status = "Backlog"
        tags = @("gameplay", "camera")
        priority = 2
        container = "86a7a1ddt" # Features
    },
    
    # UI Tasks
    @{
        name = "Create main menu UI"
        description = "Design and implement the main menu UI with options for starting a new game, loading a saved game, settings, and quitting."
        status = "Backlog"
        tags = @("ui")
        priority = 3
        container = "86a7a1ddy" # UI/UX Improvements
    },
    @{
        name = "Implement in-game HUD"
        description = "Create the in-game heads-up display showing player health, inventory, and other relevant information."
        status = "Backlog"
        tags = @("ui", "hud")
        priority = 3
        container = "86a7a1ddy" # UI/UX Improvements
    }
)

# Create each task
foreach ($task in $initialTasks) {
    Write-Host "Creating task: $($task.name)..." -ForegroundColor Yellow
    
    # Prepare task body
    $taskBody = @{
        name = $task.name
        description = $task.description
        status = $task.status
        tags = $task.tags
        priority = $task.priority
    } | ConvertTo-Json
    
    try {
        # Create the task
        $response = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/list/$listId/task" -Headers $headers -Method Post -Body $taskBody -ErrorAction Stop
        $taskId = $response.id
        Write-Host "SUCCESS! Task created with ID: $taskId" -ForegroundColor Green
        
        # Add a comment linking to the container task
        $commentBody = @{
            comment_text = "This task is categorized under #$($task.container)"
        } | ConvertTo-Json
        
        $commentResponse = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$taskId/comment" -Headers $headers -Method Post -Body $commentBody -ErrorAction Stop
        Write-Host "Added container reference comment" -ForegroundColor Green
    } catch {
        Write-Host "ERROR: Failed to create task: $($task.name)" -ForegroundColor Red
        Write-Host "Error details: $_" -ForegroundColor Red
        
        # Try to get more details from the response
        try {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $reader.BaseStream.Position = 0
            $reader.DiscardBufferedData()
            $responseBody = $reader.ReadToEnd()
            Write-Host "Response body: $responseBody" -ForegroundColor Red
        } catch {
            Write-Host "Could not read response body: $_" -ForegroundColor Red
        }
    }
}

Write-Host "`nTask creation completed!" -ForegroundColor Cyan
Write-Host "Check your ClickUp workspace to see the new tasks." -ForegroundColor Cyan 