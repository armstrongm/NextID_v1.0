Write-Host "Git Auto-Sync" -ForegroundColor Cyan
Write-Host ""

# Pull latest changes
Write-Host "Pulling latest changes..." -ForegroundColor Yellow
git pull origin main

# Add all changes
Write-Host "Adding changes..." -ForegroundColor Yellow
git add .

# Check if there are changes
$status = git status --porcelain
if ($status) {
    # Commit with timestamp
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $message = Read-Host "Commit message (or press Enter for auto-message)"
    
    if ([string]::IsNullOrWhiteSpace($message)) {
        $message = "Auto-sync: $timestamp"
    }
    
    git commit -m $message
    
    # Push to remote
    Write-Host "Pushing to remote..." -ForegroundColor Yellow
    git push origin main
    
    Write-Host ""
    Write-Host "Sync complete!" -ForegroundColor Green
} else {
    Write-Host "No changes to commit" -ForegroundColor Yellow
}