param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('backend', 'frontend', 'postgres')]
    [string]$Service
)

Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Opening $Service Container Shell" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

switch ($Service) {
    'backend' {
        docker-compose exec backend sh
    }
    'postgres' {
        docker-compose exec postgres psql -U iam_user -d iam_db
    }
    'frontend' {
        docker-compose exec frontend sh
    }
}