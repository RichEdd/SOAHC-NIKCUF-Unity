param(
    [Parameter(Mandatory=$true)]
    [string]$TaskName,
    
    [Parameter(Mandatory=$false)]
    [string]$Description = "",
    
    [Parameter(Mandatory=$false)]
    [string]$Status = "Backlog",
    
    [Parameter(Mandatory=$false)]
    [string]$ContainerId = ""
)

# ClickUp API credentials
$token = "pk_132021316_3Y2JWD1NM4GGY3RV63JJ01PFUA9PQCQJ"
$teamId = "9013790997"

# Set up headers for API requests
$headers = @{
    "Authorization" = $token
    "Content-Type" = "application/json"
}

# First, get the first space
$spacesUrl = "https://api.clickup.com/api/v2/team/$teamId/space"
$spacesResponse = Invoke-RestMethod -Uri $spacesUrl -Headers $headers -Method Get

if ($spacesResponse.spaces.Count -eq 0) {
    Write-Host "No spaces found in the team." -ForegroundColor Red
    exit 1
}

$firstSpace = $spacesResponse.spaces[0]
Write-Host "Using space: $($firstSpace.name)" -ForegroundColor Cyan

# Get the first list in the space
$listsUrl = "https://api.clickup.com/api/v2/space/$($firstSpace.id)/list"
$listsResponse = Invoke-RestMethod -Uri $listsUrl -Headers $headers -Method Get

if ($listsResponse.lists.Count -eq 0) {
    Write-Host "No lists found in the space." -ForegroundColor Red
    exit 1
}

$firstList = $listsResponse.lists[0]
Write-Host "Using list: $($firstList.name)" -ForegroundColor Cyan

# Prepare the task data
$taskData = @{
    name = $TaskName
    description = $Description
    status = $Status
}

# Add parent if ContainerId is provided
if ($ContainerId) {
    $taskData.parent = $ContainerId
}

# Convert to JSON
$jsonBody = $taskData | ConvertTo-Json

# Create the task
$createTaskUrl = "https://api.clickup.com/api/v2/list/$($firstList.id)/task"
try {
    $response = Invoke-RestMethod -Uri $createTaskUrl -Headers $headers -Method Post -Body $jsonBody
    Write-Host "Task created successfully!" -ForegroundColor Green
    Write-Host "Task ID: $($response.id)" -ForegroundColor Green
    Write-Host "Task URL: $($response.url)" -ForegroundColor Cyan
} catch {
    Write-Host "Error creating task: $_" -ForegroundColor Red
    Write-Host "Response: $($_.Exception.Response.GetResponseStream())" -ForegroundColor Red
} 