# Get ClickUp Statuses Script
# This script helps you find the available statuses in your ClickUp list

$apiToken = "pk_132021316_3Y2JWD1NM4GGY3RV63JJ01PFUA9PQCQJ"
$listId = "901308586205" # The list ID we just created

Write-Host "Getting ClickUp Statuses..." -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan
Write-Host ""

# Create auth header
$headers = @{
    Authorization = $apiToken
    "Content-Type" = "application/json"
}

# Get list information
try {
    $response = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/list/$listId" -Headers $headers -Method Get -ErrorAction Stop
    
    if ($response.statuses) {
        Write-Host "SUCCESS! Found statuses for list '$($response.name)':" -ForegroundColor Green
        foreach ($status in $response.statuses) {
            Write-Host "Status Name: $($status.status)" -ForegroundColor Green
            Write-Host "Status ID: $($status.id)" -ForegroundColor Green
            Write-Host "Status Color: $($status.color)" -ForegroundColor Green
            Write-Host "------------------------" -ForegroundColor Green
        }
        
        # Save the first status to use in our task creation
        $firstStatus = $response.statuses[0].status
        Write-Host "`nWe'll use the status '$firstStatus' for creating tasks." -ForegroundColor Cyan
        
        # Update the simplified script with the correct status
        $scriptPath = "setup-clickup-containers-simplified.ps1"
        $scriptContent = Get-Content $scriptPath -Raw
        $updatedContent = $scriptContent -replace "status = `"to do`"", "status = `"$firstStatus`""
        $updatedContent | Out-File -FilePath $scriptPath
        
        Write-Host "Updated the setup script with the correct status." -ForegroundColor Green
    } else {
        Write-Host "No statuses found for this list." -ForegroundColor Yellow
    }
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
    
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

Write-Host "`nScript completed!" -ForegroundColor Cyan 