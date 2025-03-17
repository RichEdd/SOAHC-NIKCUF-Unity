# Load the ClickUp API functions
. .\direct-clickup-api.ps1

# Performance Optimization Container ID from the reference document
$performanceContainerId = "86a7a1ddw"

# Task details
$taskName = "Fix CLI-GIT-Cursor-Unity workflow"
$taskDescription = "Optimize the workflow between CLI tools, Git, Cursor IDE, and Unity to improve development efficiency and performance."

# Create the task in the Performance Optimization container
$task = New-ClickUpTaskInContainer -Name $taskName -Description $taskDescription -ContainerId $performanceContainerId -Status "Backlog"

if ($task) {
    Write-Host "Task created successfully in the Performance Optimization container!" -ForegroundColor Green
    Write-Host "You can view the task at: $($task.url)" -ForegroundColor Cyan
} 