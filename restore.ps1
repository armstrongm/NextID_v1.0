param(
    [Parameter(Mandatory=$true)]
    [string]$BackupFile
)

Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Restoring from: $BackupFile" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $BackupFile)) {
    Write-Host "Error: Backup file not found: $BackupFile" -ForegroundColor Red
    Write-Host ""
    Write-Host "Available backups:" -ForegroundColor Yellow
    Get-ChildItem -Path ".\backups" -Filter "*.zip" | Select-Object Name
    exit 1
}

$confirm = Read-Host "This will overwrite the current database. Continue? (y/N)"

if ($confirm -ne 'y' -and $confirm -ne 'Y') {
    Write-Host "Cancelled" -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Extracting backup..." -ForegroundColor Yellow
$TempDir = ".\backups\temp"
Expand-Archive -Path $BackupFile -DestinationPath $TempDir -Force

Write-Host ""
Write-Host "Restoring database..." -ForegroundColor Yellow
Get-ChildItem -Path $TempDir -Filter "*.sql" | ForEach-Object {
    Get-Content $_.FullName | docker-compose exec -T postgres psql -U iam_user -d iam_db
}

Write-Host ""
Write-Host "Cleaning up..." -ForegroundColor Yellow
Remove-Item -Path $TempDir -Recurse -Force

Write-Host ""
Write-Host "====================================" -ForegroundColor Green
Write-Host "Restore complete!" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green