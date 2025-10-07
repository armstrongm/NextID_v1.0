Write-Host "====================================" -ForegroundColor Cyan
Write-Host "IAM Application Complete Setup" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# Create directory structure
Write-Host "Creating directory structure..." -ForegroundColor Yellow

$directories = @(
    "backend/src/main/java/com/company/iam",
    "backend/src/main/resources/db/migration",
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
    }
}

Write-Host ""
Write-Host "Creating frontend files..." -ForegroundColor Yellow

# Create frontend/package.json
@'
{
  "name": "iam-frontend",
  "version": "1.0.0",
  "private": true,
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-scripts": "5.0.1",
    "axios": "^1.6.0",
    "lucide-react": "^0.294.0"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject"
  },
  "eslintConfig": {
    "extends": [
      "react-app"
    ]
  },
  "browserslist": {
    "production": [
      ">0.2%",
      "not dead",
      "not op_mini all"
    ],
    "development": [
      "last 1 chrome version",
      "last 1 firefox version",
      "last 1 safari version"
    ]
  }
}
'@ | Out-File -FilePath "frontend/package.json" -Encoding UTF8
Write-Host "  Created: frontend/package.json" -ForegroundColor Green

# Create frontend/Dockerfile
@'
# Multi-stage build for React application

# Stage 1: Build
FROM node:18-alpine AS build
WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy source and build
COPY . .
RUN npm run build

# Stage 2: Serve with Nginx
FROM nginx:1.25-alpine
WORKDIR /usr/share/nginx/html

# Remove default nginx static files
RUN rm -rf ./*

# Copy built app from build stage
COPY --from=build /app/build .

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Create nginx user
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html

# Expose port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
'@ | Out-File -FilePath "frontend/Dockerfile" -Encoding UTF8
Write-Host "  Created: frontend/Dockerfile" -ForegroundColor Green

# Create frontend/.dockerignore
@'
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
'@ | Out-File -FilePath "frontend/.dockerignore" -Encoding UTF8
Write-Host "  Created: frontend/.dockerignore" -ForegroundColor Green

# Create frontend/nginx.conf
@'
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # React Router - serve index.html for all routes
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Proxy API requests to backend
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

    # Error pages
    error_page 404 /index.html;
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }
}
'@ | Out-File -FilePath "frontend/nginx.conf" -Encoding UTF8
Write-Host "  Created: frontend/nginx.conf" -ForegroundColor Green

# Create frontend/public/index.html
@'
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="theme-color" content="#000000" />
    <meta name="description" content="IAM Application - Identity and Access Management" />
    <title>IAM Portal</title>
  </head>
  <body>
    <noscript>You need to enable JavaScript to run this app.</noscript>
    <div id="root"></div>
  </body>
</html>
'@ | Out-File -FilePath "frontend/public/index.html" -Encoding UTF8
Write-Host "  Created: frontend/public/index.html" -ForegroundColor Green

# Create frontend/src/index.js
@'
import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import App from './App';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
'@ | Out-File -FilePath "frontend/src/index.js" -Encoding UTF8
Write-Host "  Created: frontend/src/index.js" -ForegroundColor Green

# Create frontend/src/index.css
@'
@tailwind base;
@tailwind components;
@tailwind utilities;

body {
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
    'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',
    sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

code {
  font-family: source-code-pro, Menlo, Monaco, Consolas, 'Courier New',
    monospace;
}
'@ | Out-File -FilePath "frontend/src/index.css" -Encoding UTF8
Write-Host "  Created: frontend/src/index.css" -ForegroundColor Green

# Create tailwind.config.js
@'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{js,jsx,ts,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
'@ | Out-File -FilePath "frontend/tailwind.config.js" -Encoding UTF8
Write-Host "  Created: frontend/tailwind.config.js" -ForegroundColor Green

# Create postcss.config.js
@'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
'@ | Out-File -FilePath "frontend/postcss.config.js" -Encoding UTF8
Write-Host "  Created: frontend/postcss.config.js" -ForegroundColor Green

Write-Host ""
Write-Host "Creating docker-compose.yml..." -ForegroundColor Yellow

# Create docker-compose.yml
@'
version: '3.8'

services:
  # PostgreSQL Database
  postgres:
    image: postgres:15-alpine
    container_name: iam-postgres
    restart: unless-stopped
    environment:
      POSTGRES_DB: ${DB_NAME:-iam_db}
      POSTGRES_USER: ${DB_USER:-iam_user}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      PGDATA: /var/lib/postgresql/data/pgdata
    ports:
      - "${DB_PORT:-5432}:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - iam-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER:-iam_user} -d ${DB_NAME:-iam_db}"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Spring Boot Backend
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: iam-backend
    restart: unless-stopped
    depends_on:
      postgres:
        condition: service_healthy
    environment:
      # Database
      SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/${DB_NAME:-iam_db}
      SPRING_DATASOURCE_USERNAME: ${DB_USER:-iam_user}
      SPRING_DATASOURCE_PASSWORD: ${DB_PASSWORD}
      
      # JPA/Hibernate
      SPRING_JPA_HIBERNATE_DDL_AUTO: validate
      SPRING_JPA_SHOW_SQL: ${SHOW_SQL:-false}
      
      # Flyway
      SPRING_FLYWAY_ENABLED: true
      SPRING_FLYWAY_BASELINE_ON_MIGRATE: true
      
      # JWT
      JWT_SECRET: ${JWT_SECRET}
      JWT_EXPIRATION: ${JWT_EXPIRATION:-86400000}
      
      # Server
      SERVER_PORT: 8080
      SPRING_PROFILES_ACTIVE: ${SPRING_PROFILES_ACTIVE:-prod}
      
      # Logging
      LOGGING_LEVEL_COM_COMPANY_IAM: ${LOG_LEVEL:-INFO}
      
      # CORS
      CORS_ALLOWED_ORIGINS: ${CORS_ORIGINS:-http://localhost:3000}
    ports:
      - "${BACKEND_PORT:-8080}:8080"
    volumes:
      - backend_logs:/app/logs
    networks:
      - iam-network
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:8080/api/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s

  # React Frontend with Nginx
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: iam-frontend
    restart: unless-stopped
    depends_on:
      - backend
    ports:
      - "${FRONTEND_PORT:-3000}:80"
    networks:
      - iam-network
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost/"]
      interval: 30s
      timeout: 10s
      retries: 3

networks:
  iam-network:
    driver: bridge
    name: iam-network

volumes:
  postgres_data:
    driver: local
    name: iam-postgres-data
  backend_logs:
    driver: local
    name: iam-backend-logs
'@ | Out-File -FilePath "docker-compose.yml" -Encoding UTF8
Write-Host "  Created: docker-compose.yml" -ForegroundColor Green

Write-Host ""
Write-Host "Creating .env file..." -ForegroundColor Yellow

# Create .env
@'
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
'@ | Out-File -FilePath ".env" -Encoding UTF8
Write-Host "  Created: .env" -ForegroundColor Green

Write-Host ""
Write-Host "Creating backend/.dockerignore..." -ForegroundColor Yellow

# Create backend/.dockerignore
@'
target/
.mvn/
mvnw
mvnw.cmd
*.log
.git/
.gitignore
*.md
Dockerfile
.dockerignore
.env
'@ | Out-File -FilePath "backend/.dockerignore" -Encoding UTF8
Write-Host "  Created: backend/.dockerignore" -ForegroundColor Green

Write-Host ""
Write-Host "====================================" -ForegroundColor Green
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Copy the React App code to frontend/src/App.js" -ForegroundColor White
Write-Host "2. Install frontend dependencies: cd frontend && npm install" -ForegroundColor White
Write-Host "3. Run validation: .\validate.ps1" -ForegroundColor White
Write-Host "4. Build images: .\build.ps1" -ForegroundColor White
Write-Host "5. Start application: .\start.ps1" -ForegroundColor White