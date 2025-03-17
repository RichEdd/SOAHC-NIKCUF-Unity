# Get ClickUp Teams Script
# This script helps you find your ClickUp Team ID

$apiToken = "pk_132021316_3Y2JWD1NM4GGY3RV63JJ01PFUA9PQCQJ"

Write-Host "Getting ClickUp Teams..." -ForegroundColor Cyan
Write-Host "======================" -ForegroundColor Cyan
Write-Host ""

# Create auth header
$headers = @{
    Authorization = $apiToken
    "Content-Type" = "application/json"
}

# Get teams
try {
    $response = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/team" -Headers $headers -Method Get -ErrorAction Stop
    
    if ($response.teams) {
        Write-Host "SUCCESS! Found teams:" -ForegroundColor Green
        foreach ($team in $response.teams) {
            Write-Host "Team Name: $($team.name)" -ForegroundColor Green
            Write-Host "Team ID: $($team.id)" -ForegroundColor Green
            Write-Host "------------------------" -ForegroundColor Green
            
            # Update the config file with the team ID
            $configPath = "clickup-config.json"
            $config = Get-Content $configPath | ConvertFrom-Json
            $config.team = $team.id
            $config | ConvertTo-Json | Out-File -FilePath $configPath
            
            Write-Host "Updated config file with Team ID: $($team.id)" -ForegroundColor Green
            
            # Get spaces
            try {
                $spacesResponse = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/team/$($team.id)/space" -Headers $headers -Method Get -ErrorAction Stop
                
                if ($spacesResponse.spaces) {
                    Write-Host "`nSpaces in this team:" -ForegroundColor Cyan
                    foreach ($space in $spacesResponse.spaces) {
                        Write-Host "Space Name: $($space.name)" -ForegroundColor Cyan
                        Write-Host "Space ID: $($space.id)" -ForegroundColor Cyan
                        Write-Host "------------------------" -ForegroundColor Cyan
                    }
                } else {
                    Write-Host "No spaces found in this team." -ForegroundColor Yellow
                }
            } catch {
                Write-Host "Error getting spaces: $_" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "No teams found." -ForegroundColor Yellow
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