# Test ClickUp-GitHub Integration Script
# This script helps you test if your ClickUp-GitHub integration is working correctly

Write-Host "ClickUp-GitHub Integration Test" -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check if git is installed
Write-Host "[Step 1] Checking if Git is installed..." -ForegroundColor Yellow
try {
    $gitVersion = git --version
    Write-Host "SUCCESS: Git is installed: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Git is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Git from https://git-scm.com/downloads" -ForegroundColor Red
    exit
}

# Step 2: Check if the current directory is a git repository
Write-Host "`n[Step 2] Checking if current directory is a Git repository..." -ForegroundColor Yellow
if (Test-Path ".git") {
    Write-Host "SUCCESS: Current directory is a Git repository" -ForegroundColor Green
    
    # Get remote URL
    $remoteUrl = git config --get remote.origin.url
    Write-Host "Remote URL: $remoteUrl" -ForegroundColor Green
} else {
    Write-Host "ERROR: Current directory is not a Git repository" -ForegroundColor Red
    Write-Host "Please navigate to your Git repository or initialize one with 'git init'" -ForegroundColor Red
    exit
}

# Step 3: Select a container task
Write-Host "`n[Step 3] Selecting a container task" -ForegroundColor Yellow
Write-Host "Available container tasks (all with CONTAINERS status):" -ForegroundColor Cyan
Write-Host "1. Bug Fixes (#86a7a1ddr)" -ForegroundColor White
Write-Host "2. Features (#86a7a1ddt)" -ForegroundColor White
Write-Host "3. Refactors (#86a7a1ddv)" -ForegroundColor White
Write-Host "4. Performance Optimizations (#86a7a1ddw)" -ForegroundColor White
Write-Host "5. UI/UX Improvements (#86a7a1ddy)" -ForegroundColor White
Write-Host "6. Art & Assets (#86a7a1ddz)" -ForegroundColor White
Write-Host "7. Audio (#86a7a1de0)" -ForegroundColor White
Write-Host "8. Documentation (#86a7a1de1)" -ForegroundColor White

Write-Host "Enter the number of the container task you want to test (1-8):" -ForegroundColor Cyan
$taskChoice = Read-Host

$taskIds = @("86a7a1ddr", "86a7a1ddt", "86a7a1ddv", "86a7a1ddw", "86a7a1ddy", "86a7a1ddz", "86a7a1de0", "86a7a1de1")
$taskCategories = @("Bug Fixes", "Features", "Refactors", "Performance Optimizations", "UI/UX Improvements", "Art & Assets", "Audio", "Documentation")

if ($taskChoice -ge 1 -and $taskChoice -le 8) {
    $taskIndex = [int]$taskChoice - 1
    $taskId = $taskIds[$taskIndex]
    $taskCategory = $taskCategories[$taskIndex]
    Write-Host "Selected task: $taskCategory (#$taskId)" -ForegroundColor Green
} else {
    Write-Host "Invalid choice. Using Documentation task as default." -ForegroundColor Yellow
    $taskId = "86a7a1de1"
    $taskCategory = "Documentation"
}

# Step 4: Create a test file
$testFileName = "clickup-integration-test.txt"
Write-Host "`n[Step 4] Creating a test file: $testFileName" -ForegroundColor Yellow
$dateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$content = "ClickUp integration test file`nCreated at: $dateTime`nThis file was created to test the ClickUp-GitHub integration for the $taskCategory category."
$content | Out-File -FilePath $testFileName

# Step 5: Add the file to git
Write-Host "`n[Step 5] Adding the test file to Git" -ForegroundColor Yellow
git add $testFileName
Write-Host "SUCCESS: File added to Git" -ForegroundColor Green

# Step 6: Commit with the ClickUp task ID
$commitMessage = "Test ClickUp integration for $taskCategory #$taskId"
Write-Host "`n[Step 6] Committing with message: '$commitMessage'" -ForegroundColor Yellow
git commit -m $commitMessage
Write-Host "SUCCESS: Changes committed with ClickUp task ID" -ForegroundColor Green

# Step 7: Ask if user wants to push
Write-Host "`n[Step 7] Push changes to remote repository?" -ForegroundColor Yellow
Write-Host "Do you want to push the changes to the remote repository? (y/n)" -ForegroundColor Cyan
$pushResponse = Read-Host

if ($pushResponse -eq "y" -or $pushResponse -eq "Y") {
    Write-Host "Pushing changes to remote repository..." -ForegroundColor Yellow
    git push
    Write-Host "SUCCESS: Changes pushed to remote repository" -ForegroundColor Green
    
    Write-Host "`nNext steps:" -ForegroundColor Cyan
    Write-Host "1. Go to your ClickUp task: #$taskId" -ForegroundColor White
    Write-Host "2. Check if the commit appears in the task's activity" -ForegroundColor White
    Write-Host "3. If it doesn't appear within a few minutes, check your ClickUp-GitHub integration settings" -ForegroundColor White
} else {
    Write-Host "Changes were not pushed to the remote repository" -ForegroundColor Yellow
    Write-Host "You can push them later with 'git push'" -ForegroundColor Yellow
}

Write-Host "`nTest completed!" -ForegroundColor Cyan 