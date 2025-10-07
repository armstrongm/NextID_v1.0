Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Validating IAM Application Setup" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

$errors = 0

# Check pom.xml exists
Write-Host "Checking backend/pom.xml..." -ForegroundColor Yellow
if (Test-Path "backend/pom.xml") {
    $pomContent = Get-Content "C:\myNextJsProject\nextID\backend\pom.xml" -Raw
    
    # Check if it's a valid XML
    try {
        [xml]$pomXml = $pomContent
        
        # Check for required elements
        if ($pomXml.project -eq $null) {
            Write-Host "  ERROR: Missing <project> root element" -ForegroundColor Red
            $errors++
        } elseif ($pomXml.project.modelVersion -eq $null) {
            Write-Host "  ERROR: Missing <modelVersion>" -ForegroundColor Red
            $errors++
        } elseif ($pomXml.project.groupId -eq $null -and $pomXml.project.parent.groupId -eq $null) {
            Write-Host "  ERROR: Missing <groupId>" -ForegroundColor Red
            $errors++
        } elseif ($pomXml.project.artifactId -eq $null) {
            Write-Host "  ERROR: Missing <artifactId>" -ForegroundColor Red
            $errors++
        } else {
            Write-Host "  OK: pom.xml is valid" -ForegroundColor Green
        }
    } catch {
        Write-Host "  ERROR: pom.xml is not valid XML" -ForegroundColor Red
        Write-Host "  $_" -ForegroundColor Red
        $errors++
    }
} else {
    Write-Host "  ERROR: backend/pom.xml not found" -ForegroundColor Red
    $errors++
}

# Check Dockerfile exists
Write-Host "Checking C:\myNextJsProject\nextID\backend\Dockerfile..." -ForegroundColor Yellow
if (Test-Path "C:\myNextJsProject\nextID\backend\Dockerfile") {
    Write-Host "  OK: Dockerfile found" -ForegroundColor Green
} else {
    Write-Host "  ERROR: backend/Dockerfile not found" -ForegroundColor Red
    $errors++
}

# Check src directory
Write-Host "Checking backend/src..." -ForegroundColor Yellow
if (Test-Path "C:\myNextJsProject\nextID\backend\src\main\java") {
    Write-Host "  OK: src/main/java found" -ForegroundColor Green
} else {
    Write-Host "  WARNING: backend/src/main/java not found" -ForegroundColor Yellow
}

# Check resources directory
Write-Host "Checking backend/src/main/resources..." -ForegroundColor Yellow
if (Test-Path "C:\myNextJsProject\nextID\backend\src\main\resources") {
    Write-Host "  OK: resources directory found" -ForegroundColor Green
} else {
    Write-Host "  WARNING: backend/src/main/resources not found" -ForegroundColor Yellow
}

# Check migration files
Write-Host "Checking Flyway migrations..." -ForegroundColor Yellow
if (Test-Path "backend/src/main/resources/db/migration") {
    $migrations = Get-ChildItem "backend/src/main/resources/db/migration" -Filter "V*.sql"
    if ($migrations.Count -gt 0) {
        Write-Host "  OK: Found $($migrations.Count) migration file(s)" -ForegroundColor Green
    } else {
        Write-Host "  WARNING: No migration files found" -ForegroundColor Yellow
    }
} else {
    Write-Host "  WARNING: Migration directory not found" -ForegroundColor Yellow
}

# Check frontend
Write-Host "Checking frontend/package.json..." -ForegroundColor Yellow
if (Test-Path "frontend/package.json") {
    Write-Host "  OK: package.json found" -ForegroundColor Green
} else {
    Write-Host "  ERROR: frontend/package.json not found" -ForegroundColor Red
    $errors++
}

Write-Host "Checking frontend/Dockerfile..." -ForegroundColor Yellow
if (Test-Path "frontend/Dockerfile") {
    Write-Host "  OK: Dockerfile found" -ForegroundColor Green
} else {
    Write-Host "  ERROR: frontend/Dockerfile not found" -ForegroundColor Red
    $errors++
}

# Check docker-compose.yml
Write-Host "Checking docker-compose.yml..." -ForegroundColor Yellow
if (Test-Path "docker-compose.yml") {
    Write-Host "  OK: docker-compose.yml found" -ForegroundColor Green
} else {
    Write-Host "  ERROR: docker-compose.yml not found" -ForegroundColor Red
    $errors++
}

# Check .env
Write-Host "Checking .env..." -ForegroundColor Yellow
if (Test-Path ".env") {
    Write-Host "  OK: .env found" -ForegroundColor Green
} else {
    Write-Host "  WARNING: .env not found (will use defaults)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "====================================" -ForegroundColor Cyan

if ($errors -eq 0) {
    Write-Host "Validation passed! Ready to build." -ForegroundColor Green
    Write-Host "====================================" -ForegroundColor Green
    exit 0
} else {
    Write-Host "Validation failed with $errors error(s)" -ForegroundColor Red
    Write-Host "====================================" -ForegroundColor Red
    exit 1
}