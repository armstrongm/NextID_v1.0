Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Fixing Flyway Dependency Issue" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

$pomPath = "backend/pom.xml"

if (-not (Test-Path $pomPath)) {
    Write-Host "ERROR: backend/pom.xml not found!" -ForegroundColor Red
    exit 1
}

Write-Host "Reading pom.xml..." -ForegroundColor Yellow
$content = Get-Content $pomPath -Raw

Write-Host "Checking for flyway-database-postgresql..." -ForegroundColor Yellow

if ($content -match 'flyway-database-postgresql') {
    Write-Host "Found flyway-database-postgresql dependency" -ForegroundColor Yellow
    Write-Host "Creating backup..." -ForegroundColor Yellow
    Copy-Item $pomPath "$pomPath.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
    
    Write-Host "Removing problematic dependency..." -ForegroundColor Yellow
    
    # Remove the entire dependency block
    $content = $content -replace '(?s)\s*<dependency>\s*<groupId>org\.flywaydb</groupId>\s*<artifactId>flyway-database-postgresql</artifactId>.*?</dependency>', ''
    
    # Also remove the flyway.version property if it exists
    $content = $content -replace '\s*<flyway\.version>.*?</flyway\.version>', ''
    
    Set-Content $pomPath $content -Encoding UTF8
    
    Write-Host "Removed flyway-database-postgresql dependency" -ForegroundColor Green
} else {
    Write-Host "flyway-database-postgresql not found in pom.xml" -ForegroundColor Green
}

Write-Host ""
Write-Host "====================================" -ForegroundColor Green
Write-Host "Fix Complete!" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green
Write-Host ""
Write-Host "Validating pom.xml..." -ForegroundColor Yellow

Push-Location backend
mvn validate
$exitCode = $LASTEXITCODE
Pop-Location

if ($exitCode -eq 0) {
    Write-Host ""
    Write-Host "Validation successful! Ready to build." -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "Validation failed. Please check the output above." -ForegroundColor Red
}