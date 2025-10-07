$BackupDir = ".\backups"
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$BackupFile = "$BackupDir\iam_db_$Timestamp.sql"

Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Creating Database Backup" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# Create backup directory if it doesn't exist
if (-not (Test-Path $BackupDir)) {
    New-Item -ItemType Directory -Path $BackupDir | Out-Null
}

Write-Host "Creating backup: $BackupFile" -ForegroundColor Yellow
docker-compose exec -T postgres pg_dump -U iam_user iam_db | Out-File -Encoding UTF8 $BackupFile

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error creating backup!" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host ""
Write-Host "Compressing backup..." -ForegroundColor Yellow
Compress-Archive -Path $BackupFile -DestinationPath "$BackupFile.zip"
Remove-Item $BackupFile

Write-Host ""
Write-Host "====================================" -ForegroundColor Green
Write-Host "Backup created: $BackupFile.zip" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green

# Clean old backups (older than 7 days)
Write-Host "Cleaning old backups..." -ForegroundColor Yellow
Get-ChildItem -Path $BackupDir -Filter "*.zip" | 
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) } | 
    Remove-Item

Write-Host "====================================" -ForegroundColor Green
Write-Host "Backup complete!" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green