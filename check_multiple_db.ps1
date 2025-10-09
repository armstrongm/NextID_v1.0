Write-Host "=== CHECKING FOR MULTIPLE DATABASES ===" -ForegroundColor Cyan
Write-Host ""

# Check all postgres containers
Write-Host "Docker containers:" -ForegroundColor Yellow
docker ps -a | Select-String "postgres"

# Check all processes on port 5432
Write-Host "`nProcesses on port 5432:" -ForegroundColor Yellow
netstat -ano | findstr :5432

# Check all postgres processes
Write-Host "`nPostgreSQL processes:" -ForegroundColor Yellow
Get-Process | Where-Object {$_.ProcessName -like "*postgres*"} | Format-Table -AutoSize