Write-Host ""
Write-Host "=== REMOVING ALL VOLUMES ===" -ForegroundColor Cyan
Write-Host ""

docker volume rm iam-postgres-data -f 2>$null
docker volume rm iam_postgres_data -f 2>$null
docker volume rm nextid_postgres_data -f 2>$null
docker volume prune -af

Write-Host "✓ All volumes removed" -ForegroundColor Green