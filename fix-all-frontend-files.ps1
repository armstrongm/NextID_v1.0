Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Fixing All Frontend Files (No BOM)" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

function Write-FileNoBom {
    param([string]$FilePath, [string]$Content)
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($FilePath, $Content, $utf8NoBom)
}

# 1. nginx.conf
Write-Host "Creating nginx.conf..." -ForegroundColor Yellow
$nginxConfig = @'
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;

    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api/ {
        proxy_pass http://backend:8080/api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    error_page 404 /index.html;
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }
}
'@
Write-FileNoBom -FilePath "C:\myNextJsProject\nextID\frontend\nginx.conf" -Content $nginxConfig
Write-Host "  ✓ nginx.conf" -ForegroundColor Green

# 2. .dockerignore
Write-Host "Creating .dockerignore..." -ForegroundColor Yellow
$dockerignore = @'
node_modules/
build/
.git/
.gitignore
*.md
.env.local
.env.development
.env.test
npm-debug.log*
yarn-debug.log*
yarn-error.log*
Dockerfile
.dockerignore
'@
Write-FileNoBom -FilePath "C:\myNextJsProject\nextID\frontend\.dockerignore" -Content $dockerignore
Write-Host "  ✓ .dockerignore" -ForegroundColor Green

# 3. Dockerfile
Write-Host "Creating Dockerfile..." -ForegroundColor Yellow
$dockerfile = @'
FROM node:18-alpine AS build
WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

FROM nginx:1.25-alpine
WORKDIR /usr/share/nginx/html

RUN rm -rf ./*

COPY --from=build /app/build .
COPY nginx.conf /etc/nginx/conf.d/default.conf

RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
'@
Write-FileNoBom -FilePath "C:\myNextJsProject\nextID\frontend\Dockerfile" -Content $dockerfile
Write-Host "  ✓ Dockerfile" -ForegroundColor Green

Write-Host ""
Write-Host "Verifying files have no BOM..." -ForegroundColor Yellow

$files = @("C:\myNextJsProject\nextID\frontend\nginx.conf", "C:\myNextJsProject\nextID\frontend\Dockerfile", "C:\myNextJsProject\nextID\frontend\.dockerignore")
$allClean = $true

foreach ($file in $files) {
    if (Test-Path $file) {
        $bytes = [System.IO.File]::ReadAllBytes($file)
        $hasBOM = ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)
        
        if ($hasBOM) {
            Write-Host "  ✗ $file has BOM" -ForegroundColor Red
            $allClean = $false
        } else {
            Write-Host "  ✓ $file is clean" -ForegroundColor Green
        }
    }
}

if (-not $allClean) {
    Write-Host ""
    Write-Host "ERROR: Some files still have BOM!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Building React app..." -ForegroundColor Yellow
Push-Location frontend

if (Test-Path "build") {
    Remove-Item -Recurse -Force build
}

npm run build

if ($LASTEXITCODE -ne 0) {
    Write-Host "React build failed!" -ForegroundColor Red
    Pop-Location
    exit 1
}

Write-Host "  ✓ React build successful" -ForegroundColor Green
Pop-Location

Write-Host ""
Write-Host "Stopping old containers..." -ForegroundColor Yellow
docker-compose down

Write-Host ""
Write-Host "Building Docker image..." -ForegroundColor Yellow
docker-compose build --no-cache frontend

if ($LASTEXITCODE -ne 0) {
    Write-Host "Docker build failed!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Starting containers..." -ForegroundColor Yellow
docker-compose up -d

Write-Host ""
Write-Host "Waiting for containers to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

Write-Host ""
Write-Host "Container status:" -ForegroundColor Yellow
docker-compose ps

Write-Host ""
$status = docker inspect --format='{{.State.Status}}' iam-frontend 2>$null

if ($status -eq "running") {
    Write-Host "====================================" -ForegroundColor Green
    Write-Host "✓ SUCCESS!" -ForegroundColor Green
    Write-Host "====================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Frontend: http://localhost:3000" -ForegroundColor Cyan
    Write-Host "Backend:  http://localhost:8080/api/health" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Login with: admin / admin123" -ForegroundColor Yellow
} else {
    Write-Host "====================================" -ForegroundColor Red
    Write-Host "✗ Frontend failed to start" -ForegroundColor Red
    Write-Host "====================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Checking logs..." -ForegroundColor Yellow
    docker logs iam-frontend
}