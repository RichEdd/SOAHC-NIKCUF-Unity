# Setup ClickUp Container Tasks Script (Final)
# This script helps you set up container tasks in ClickUp for your Unity project

$apiToken = "pk_132021316_3Y2JWD1NM4GGY3RV63JJ01PFUA9PQCQJ"
$listId = "901308586205" # The list ID we already created

Write-Host "ClickUp Container Tasks Setup" -ForegroundColor Cyan
Write-Host "============================" -ForegroundColor Cyan
Write-Host ""

# Create auth header
$headers = @{
    Authorization = $apiToken
    "Content-Type" = "application/json"
}

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

# Create tasks in the list
Write-Host "[Step 1] Creating container tasks in the existing list..." -ForegroundColor Yellow
foreach ($task in $containerTasks) {
    Write-Host "Creating task: $($task.name)..." -ForegroundColor Yellow
    
    $taskBody = @{
        name = $task.name
        description = $task.description
        status = "backlog"
    } | ConvertTo-Json
    
    try {
        $taskResponse = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/list/$listId/task" -Headers $headers -Method Post -Body $taskBody -ErrorAction Stop
        $taskId = $taskResponse.id
        Write-Host "SUCCESS! Task created with ID: $taskId" -ForegroundColor Green
        Write-Host "Use this in commit messages: #$taskId" -ForegroundColor Green
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

Write-Host "`nSetup completed!" -ForegroundColor Cyan
Write-Host "Remember to use the task IDs in your commit messages with the # symbol." -ForegroundColor Cyan
Write-Host "Example: git commit -m 'Fix player collision detection #TASK_ID'" -ForegroundColor Cyan 