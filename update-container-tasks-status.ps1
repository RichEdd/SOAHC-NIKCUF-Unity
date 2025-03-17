# Update Container Tasks Status Script
# This script updates the status of container tasks to "CONTAINERS"

$apiToken = "pk_132021316_3Y2JWD1NM4GGY3RV63JJ01PFUA9PQCQJ"

Write-Host "Updating Container Tasks Status" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan
Write-Host ""

# Create auth header
$headers = @{
    Authorization = $apiToken
    "Content-Type" = "application/json"
}

# Container task IDs
$containerTaskIds = @(
    "86a7a1ddr", # Bug Fixes
    "86a7a1ddt", # Features
    "86a7a1ddv", # Refactors
    "86a7a1ddw", # Performance Optimizations
    "86a7a1ddy", # UI/UX Improvements
    "86a7a1ddz", # Art & Assets
    "86a7a1de0", # Audio
    "86a7a1de1"  # Documentation
)

$taskCategories = @(
    "Bug Fixes",
    "Features",
    "Refactors",
    "Performance Optimizations",
    "UI/UX Improvements",
    "Art & Assets",
    "Audio",
    "Documentation"
)

# Update each task's status to "CONTAINERS"
for ($i = 0; $i -lt $containerTaskIds.Count; $i++) {
    $taskId = $containerTaskIds[$i]
    $taskCategory = $taskCategories[$i]
    
    Write-Host "Updating status for $taskCategory (#$taskId) to 'CONTAINERS'..." -ForegroundColor Yellow
    
    $updateBody = @{
        status = "CONTAINERS"
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$taskId" -Headers $headers -Method Put -Body $updateBody -ErrorAction Stop
        Write-Host "SUCCESS! Updated status for $taskCategory" -ForegroundColor Green
    } catch {
        Write-Host "ERROR: Failed to update status for $taskCategory" -ForegroundColor Red
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

Write-Host "`nUpdate completed!" -ForegroundColor Cyan
Write-Host "All container tasks should now have the 'CONTAINERS' status." -ForegroundColor Cyan 