Write-Host "====================================" -ForegroundColor Cyan
Write-Host "IAM Application Quick Setup" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# Create directory structure
Write-Host "Creating directory structure..." -ForegroundColor Yellow

$directories = @(
    "backend/src/main/java/com/company/iam/config",
    "backend/src/main/java/com/company/iam/controller",
    "backend/src/main/java/com/company/iam/service",
    "backend/src/main/java/com/company/iam/repository",
    "backend/src/main/java/com/company/iam/model",
    "backend/src/main/java/com/company/iam/dto",
    "backend/src/main/java/com/company/iam/exception",
    "backend/src/main/java/com/company/iam/security",
    "backend/src/main/resources/db/migration",
    "backend/src/test/java/com/company/iam",
    "frontend/src",
    "frontend/public",
    "postgres",
    "nginx",
    "backups"
)

foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "  Created: $dir" -ForegroundColor Green
    } else {
        Write-Host "  Exists: $dir" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Creating configuration files..." -ForegroundColor Yellow
Write-Host "====================================" -ForegroundColor Cyan

# Create .env if not exists
if (-not (Test-Path ".env")) {
    @"
# Database Configuration
DB_NAME=iam_db
DB_USER=iam_user
DB_PASSWORD=ChangeThisSecurePassword123!
DB_PORT=5432

# Backend Configuration
BACKEND_PORT=8080
SPRING_PROFILES_ACTIVE=prod
LOG_LEVEL=INFO
SHOW_SQL=false

# JWT Configuration
JWT_SECRET=404E635266556A586E3272357538782F413F4428472B4B6250645367566B5970ChangeThisInProduction
JWT_EXPIRATION=86400000

# Frontend Configuration
FRONTEND_PORT=3000
REACT_APP_API_URL=http://localhost:8080/api

# CORS Configuration
CORS_ORIGINS=http://localhost:3000,http://localhost:80

# PgAdmin (Optional)
PGADMIN_EMAIL=admin@iam.local
PGADMIN_PASSWORD=admin
PGADMIN_PORT=5050
"@ | Out-File -FilePath ".env" -Encoding UTF8
    Write-Host "Created .env file" -ForegroundColor Green
} else {
    Write-Host ".env already exists" -ForegroundColor Gray
}

Write-Host ""
Write-Host "====================================" -ForegroundColor Green
Write-Host "Setup complete!" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Copy the complete pom.xml to backend/pom.xml" -ForegroundColor White
Write-Host "2. Add Java source files to backend/src/main/java" -ForegroundColor White
Write-Host "3. Add React app files to frontend/src" -ForegroundColor White
Write-Host "4. Add Dockerfiles to backend/ and frontend/" -ForegroundColor White
Write-Host "5. Run .\validate.ps1 to verify setup" -ForegroundColor White
Write-Host "6. Run .\build.ps1 to build Docker images" -ForegroundColor White
Write-Host "7. Run .\start.ps1 to start the application" -ForegroundColor White