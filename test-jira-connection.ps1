# Replace these with your actual Jira credentials
$jiraBaseUrl = "https://rkeddington2020.atlassian.net" # Your Jira URL
$jiraUser = "rkeddington2020@gmail.com" # Your Jira email
$jiraToken = "ATCTT3xFfGN0E4VSKVDPCwUc9_ZzpK5JlEY6K9SW5fkemCJH-_XiY5ihtgzjRhsLSUYltkffMGUaaw1drOs0M3iPFI2OO92KX0F57LW-0QX6-XPMYwUWBtj4ocnE0LOaAlAPJmcIY_osemMxLuerOQ8z4xAj1td3RPUATnsIHxkEjrXYPwVVyuU=960ADF6D" # Your Jira API token - replace this with your actual token when running

# Don't modify below this line
Write-Host "Testing Jira connection..."
Write-Host "Base URL: $jiraBaseUrl"
Write-Host "User: $jiraUser"
Write-Host "Token: [HIDDEN]"

# Create auth header
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("${jiraUser}:${jiraToken}")))
$headers = @{
    Authorization = "Basic $base64AuthInfo"
    "Content-Type" = "application/json"
}

# Test 1: Get current user info
Write-Host "`n[TEST 1] Getting current user info..."
try {
    $response = Invoke-RestMethod -Uri "$jiraBaseUrl/rest/api/3/myself" -Headers $headers -Method Get -ErrorAction Stop
    Write-Host "SUCCESS! Connected as: $($response.displayName) ($($response.emailAddress))" -ForegroundColor Green
} catch {
    Write-Host "FAILED! Error details:" -ForegroundColor Red
    Write-Host "Status code: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    Write-Host "Message: $($_.Exception.Message)" -ForegroundColor Red
    
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
    
    Write-Host "`nAuthentication failed. Please check your Jira credentials." -ForegroundColor Red
    Write-Host "Make sure your API token is correct and doesn't contain any extra spaces or newlines." -ForegroundColor Red
    Write-Host "You can generate a new API token at: https://id.atlassian.com/manage-profile/security/api-tokens" -ForegroundColor Yellow
    
    # Exit early if authentication fails
    Write-Host "`nTests completed with errors. Please fix the authentication issues and try again." -ForegroundColor Red
    exit
}

# Test 2: List all available projects
Write-Host "`n[TEST 2] Listing all available projects..."
try {
    $response = Invoke-RestMethod -Uri "$jiraBaseUrl/rest/api/3/project" -Headers $headers -Method Get -ErrorAction Stop
    
    if ($response.Count -gt 0) {
        Write-Host "SUCCESS! Found $($response.Count) projects:" -ForegroundColor Green
        foreach ($project in $response) {
            Write-Host "- $($project.name) (Key: $($project.key), ID: $($project.id))" -ForegroundColor Green
        }
        
        Write-Host "`nPlease note the project key you want to use for your GitHub Actions workflow." -ForegroundColor Yellow
        
        # Ask for project key
        Write-Host "`nEnter the project key you want to test (from the list above):" -ForegroundColor Cyan
        $projectKey = Read-Host
        
        # Test 3: Get issue types for the selected project
        Write-Host "`n[TEST 3] Getting issue types for project '$projectKey'..."
        try {
            $projectResponse = Invoke-RestMethod -Uri "$jiraBaseUrl/rest/api/3/project/$projectKey" -Headers $headers -Method Get -ErrorAction Stop
            Write-Host "SUCCESS! Project found: $($projectResponse.name) (Key: $($projectResponse.key))" -ForegroundColor Green
            
            $issueTypes = $projectResponse.issueTypes
            if ($issueTypes) {
                Write-Host "Available issue types:" -ForegroundColor Green
                foreach ($type in $issueTypes) {
                    Write-Host "- $($type.name) (ID: $($type.id))" -ForegroundColor Green
                    if ($type.name -eq "Task") {
                        $taskTypeFound = $true
                        $taskTypeId = $type.id
                    }
                }
                
                if ($taskTypeFound) {
                    Write-Host "'Task' issue type is available in this project (ID: $taskTypeId)." -ForegroundColor Green
                    Write-Host "Use this ID in your GitHub Actions workflow." -ForegroundColor Yellow
                } else {
                    Write-Host "'Task' issue type was NOT found in this project. This could be causing your workflow to fail." -ForegroundColor Yellow
                    Write-Host "Please use one of the available issue types listed above." -ForegroundColor Yellow
                }
            } else {
                Write-Host "No issue types found for this project." -ForegroundColor Yellow
            }
        } catch {
            Write-Host "FAILED! Error details:" -ForegroundColor Red
            Write-Host "Status code: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
            Write-Host "Message: $($_.Exception.Message)" -ForegroundColor Red
            
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
    } else {
        Write-Host "No projects found in your Jira instance." -ForegroundColor Yellow
    }
} catch {
    Write-Host "FAILED! Error details:" -ForegroundColor Red
    Write-Host "Status code: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    Write-Host "Message: $($_.Exception.Message)" -ForegroundColor Red
    
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

Write-Host "`nTests completed. Please check the results above to diagnose any issues." 