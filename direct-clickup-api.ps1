# ====================================================
# DIRECT CLICKUP API ACCESS SCRIPT
# ====================================================
# This script demonstrates how to access the ClickUp API directly using PowerShell
# without requiring the ClickUp CLI.
# ====================================================

# ClickUp API credentials
$apiToken = "pk_132021316_3Y2JWD1NM4GGY3RV63JJ01PFUA9PQCQJ"
$teamId = "9013790997"

# Set up headers for API requests
$headers = @{
    "Authorization" = $apiToken
    "Content-Type" = "application/json"
}

# Function to make API requests
function Invoke-ClickUpAPI {
    param (
        [string]$Endpoint,
        [string]$Method = "GET",
        [object]$Body = $null
    )
    
    $uri = "https://api.clickup.com/api/v2$Endpoint"
    
    try {
        if ($Body) {
            $bodyJson = $Body | ConvertTo-Json -Depth 10
            $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method $Method -Body $bodyJson
        } else {
            $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method $Method
        }
        return $response
    } catch {
        Write-Host "Error calling ClickUp API: $_" -ForegroundColor Red
        Write-Host "Status Code: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
        
        if ($_.ErrorDetails.Message) {
            $errorResponse = $_.ErrorDetails.Message | ConvertFrom-Json
            Write-Host "Error Details: $($errorResponse | ConvertTo-Json)" -ForegroundColor Red
        }
        
        return $null
    }
}

# Display menu
function Show-Menu {
    Clear-Host
    Write-Host "=====================================================" -ForegroundColor Cyan
    Write-Host "  DIRECT CLICKUP API ACCESS" -ForegroundColor Cyan
    Write-Host "=====================================================" -ForegroundColor Cyan
    Write-Host "1: Get Team Information" -ForegroundColor Yellow
    Write-Host "2: List Spaces" -ForegroundColor Yellow
    Write-Host "3: List Lists" -ForegroundColor Yellow
    Write-Host "4: List Tasks" -ForegroundColor Yellow
    Write-Host "5: Create a Task" -ForegroundColor Yellow
    Write-Host "6: Update a Task" -ForegroundColor Yellow
    Write-Host "7: Get Container Tasks" -ForegroundColor Yellow
    Write-Host "8: Exit" -ForegroundColor Yellow
    Write-Host "=====================================================" -ForegroundColor Cyan
}

# Main menu loop
function Main-Menu {
    $spaceId = $null
    $listId = $null
    
    while ($true) {
        Show-Menu
        $choice = Read-Host "Enter your choice (1-8)"
        
        switch ($choice) {
            "1" {
                # Get Team Information
                Write-Host "`nGetting Team Information..." -ForegroundColor Green
                $team = Invoke-ClickUpAPI -Endpoint "/team/$teamId"
                if ($team) {
                    Write-Host "Team Information:" -ForegroundColor Green
                    Write-Host "Team ID: $($team.id)" -ForegroundColor White
                    Write-Host "Team Name: $($team.name)" -ForegroundColor White
                    Write-Host "Team Color: $($team.color)" -ForegroundColor White
                    Write-Host "Member Count: $($team.members.Count)" -ForegroundColor White
                }
                pause
            }
            "2" {
                # List Spaces
                Write-Host "`nListing Spaces..." -ForegroundColor Green
                $spaces = Invoke-ClickUpAPI -Endpoint "/team/$teamId/space"
                if ($spaces) {
                    Write-Host "Spaces:" -ForegroundColor Green
                    foreach ($space in $spaces.spaces) {
                        Write-Host "Space ID: $($space.id) - Name: $($space.name)" -ForegroundColor White
                    }
                    
                    # Ask user to select a space
                    $spaceId = Read-Host "`nEnter a Space ID to use for further operations (or press Enter to skip)"
                }
                pause
            }
            "3" {
                # List Lists
                if (-not $spaceId) {
                    Write-Host "`nPlease select a Space first (option 2)" -ForegroundColor Yellow
                    pause
                    continue
                }
                
                Write-Host "`nListing Lists for Space $spaceId..." -ForegroundColor Green
                $lists = Invoke-ClickUpAPI -Endpoint "/space/$spaceId/list"
                if ($lists) {
                    Write-Host "Lists:" -ForegroundColor Green
                    foreach ($list in $lists.lists) {
                        Write-Host "List ID: $($list.id) - Name: $($list.name)" -ForegroundColor White
                    }
                    
                    # Ask user to select a list
                    $listId = Read-Host "`nEnter a List ID to use for further operations (or press Enter to skip)"
                }
                pause
            }
            "4" {
                # List Tasks
                if (-not $listId) {
                    Write-Host "`nPlease select a List first (option 3)" -ForegroundColor Yellow
                    pause
                    continue
                }
                
                Write-Host "`nListing Tasks for List $listId..." -ForegroundColor Green
                $tasks = Invoke-ClickUpAPI -Endpoint "/list/$listId/task"
                if ($tasks) {
                    Write-Host "Tasks:" -ForegroundColor Green
                    foreach ($task in $tasks.tasks) {
                        Write-Host "Task ID: $($task.id) - Name: $($task.name) - Status: $($task.status.status)" -ForegroundColor White
                    }
                }
                pause
            }
            "5" {
                # Create a Task
                if (-not $listId) {
                    Write-Host "`nPlease select a List first (option 3)" -ForegroundColor Yellow
                    pause
                    continue
                }
                
                $taskName = Read-Host "Enter task name"
                $taskDescription = Read-Host "Enter task description"
                
                $taskBody = @{
                    name = $taskName
                    description = $taskDescription
                    status = "Backlog"
                }
                
                Write-Host "`nCreating Task..." -ForegroundColor Green
                $newTask = Invoke-ClickUpAPI -Endpoint "/list/$listId/task" -Method "POST" -Body $taskBody
                if ($newTask) {
                    Write-Host "Task Created Successfully:" -ForegroundColor Green
                    Write-Host "Task ID: $($newTask.id)" -ForegroundColor White
                    Write-Host "Task Name: $($newTask.name)" -ForegroundColor White
                    Write-Host "Task URL: $($newTask.url)" -ForegroundColor White
                }
                pause
            }
            "6" {
                # Update a Task
                $taskId = Read-Host "Enter the Task ID to update"
                $newStatus = Read-Host "Enter the new status for the task"
                
                $updateBody = @{
                    status = $newStatus
                }
                
                Write-Host "`nUpdating Task..." -ForegroundColor Green
                $updatedTask = Invoke-ClickUpAPI -Endpoint "/task/$taskId" -Method "PUT" -Body $updateBody
                if ($updatedTask) {
                    Write-Host "Task Updated Successfully:" -ForegroundColor Green
                    Write-Host "Task ID: $($updatedTask.id)" -ForegroundColor White
                    Write-Host "Task Name: $($updatedTask.name)" -ForegroundColor White
                    Write-Host "Task Status: $($updatedTask.status.status)" -ForegroundColor White
                }
                pause
            }
            "7" {
                # Get Container Tasks
                Write-Host "`nContainer Tasks:" -ForegroundColor Green
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
                
                foreach ($task in $containerTasks) {
                    # Get task details from API
                    $taskDetails = Invoke-ClickUpAPI -Endpoint "/task/$($task.id)"
                    if ($taskDetails) {
                        Write-Host "Task ID: $($taskDetails.id) - Name: $($taskDetails.name) - Status: $($taskDetails.status.status)" -ForegroundColor White
                    } else {
                        Write-Host "Task ID: $($task.id) - Name: $($task.name) - Status: Unknown" -ForegroundColor White
                    }
                }
                pause
            }
            "8" {
                # Exit
                Write-Host "`nExiting..." -ForegroundColor Green
                return
            }
            default {
                Write-Host "`nInvalid choice. Please try again." -ForegroundColor Red
                pause
            }
        }
    }
}

# Search for tasks related to .gitignore
Write-Host "Searching for tasks related to .gitignore..." -ForegroundColor Cyan

# Get all spaces in the team
$spaces = Invoke-ClickUpAPI -Endpoint "/team/$teamId/space"

if ($spaces -and $spaces.spaces) {
    foreach ($space in $spaces.spaces) {
        Write-Host "Checking space: $($space.name)" -ForegroundColor Yellow
        
        # Get all lists in the space
        $lists = Invoke-ClickUpAPI -Endpoint "/space/$($space.id)/list"
        
        if ($lists -and $lists.lists) {
            foreach ($list in $lists.lists) {
                Write-Host "  Checking list: $($list.name)" -ForegroundColor Yellow
                
                # Get all tasks in the list
                $tasks = Invoke-ClickUpAPI -Endpoint "/list/$($list.id)/task?include_closed=true"
                
                if ($tasks -and $tasks.tasks) {
                    foreach ($task in $tasks.tasks) {
                        if ($task.name -like "*gitignore*" -or $task.description -like "*gitignore*") {
                            Write-Host "`nFound task related to gitignore:" -ForegroundColor Green
                            Write-Host "  Task ID: $($task.id)" -ForegroundColor Green
                            Write-Host "  Task Name: $($task.name)" -ForegroundColor Green
                            Write-Host "  Status: $($task.status.status)" -ForegroundColor Green
                            Write-Host "  URL: $($task.url)" -ForegroundColor Green
                            Write-Host "  Description: $($task.description)" -ForegroundColor Green
                            Write-Host "  Created: $([DateTime]::FromUnixTimeMilliseconds($task.date_created).ToString())" -ForegroundColor Green
                            Write-Host "  Due Date: $(if ($task.due_date) { [DateTime]::FromUnixTimeMilliseconds($task.due_date).ToString() } else { 'None' })" -ForegroundColor Green
                        }
                    }
                }
            }
        }
    }
}

Write-Host "`nSearch completed." -ForegroundColor Cyan

# Get the first list ID from the first space
$spaces = Invoke-ClickUpAPI -Method "GET" -Endpoint "team/$teamId/space"
if ($spaces) {
    $firstSpace = $spaces[0]
    $lists = Invoke-ClickUpAPI -Method "GET" -Endpoint "space/$($firstSpace.id)/list"
    if ($lists) {
        $listId = $lists[0].id
        Write-Host "Using list ID: $listId" -ForegroundColor Green
    }
}

# Function to create a new task
function New-ClickUpTask {
    param (
        [string]$Name,
        [string]$Description,
        [string]$Status = "Backlog",
        [string]$ParentTaskId = $null
    )
    
    $body = @{
        name = $Name
        description = $Description
        status = $Status
    }
    
    if ($ParentTaskId) {
        $body.parent = $ParentTaskId
    }
    
    $jsonBody = $body | ConvertTo-Json
    
    Write-Host "Creating new task: $Name" -ForegroundColor Cyan
    $response = Invoke-ClickUpAPI -Method "POST" -Endpoint "list/$listId/task" -Body $jsonBody
    
    if ($response) {
        Write-Host "Task created successfully!" -ForegroundColor Green
        Write-Host "Task ID: $($response.id)"
        Write-Host "Task URL: $($response.url)"
    }
}

# Example usage:
# New-ClickUpTask -Name "New Feature" -Description "Implement new feature" -Status "Backlog"

# Function to create a new task in a container
function New-ClickUpTaskInContainer {
    param (
        [string]$Name,
        [string]$Description,
        [string]$ContainerId,
        [string]$Status = "Backlog"
    )
    
    $body = @{
        name = $Name
        description = $Description
        status = $Status
        parent = $ContainerId
    }
    
    $jsonBody = $body | ConvertTo-Json
    
    Write-Host "Creating new task: $Name in container $ContainerId" -ForegroundColor Cyan
    $response = Invoke-ClickUpAPI -Method "POST" -Endpoint "/list/$listId/task" -Body $jsonBody
    
    if ($response) {
        Write-Host "Task created successfully!" -ForegroundColor Green
        Write-Host "Task ID: $($response.id)"
        Write-Host "Task URL: $($response.url)"
        return $response
    }
    return $null
}

# Start the menu
Main-Menu 