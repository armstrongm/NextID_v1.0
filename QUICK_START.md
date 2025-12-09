$quickStart = @'
# Quick Start Guide - JWT Authentication & User Service

## Prerequisites

- Docker Desktop running
- PowerShell
- Git configured

## Installation Steps

### 1. Create All Backend Files
```powershell
# Create JWT implementation
.\create-jwt-implementation.ps1

# Create user service models
.\create-user-service.ps1

# Create DTOs and services
.\create-user-dto-service.ps1

# Create service implementations
.\create-services-impl.ps1

# Create controllers
.\create-controllers.ps1
```

### 2. Create Frontend API Integration
```powershell
.\create-frontend-api.ps1
```

### 3. Deploy Everything
```powershell
# One command to deploy everything
.\deploy-full-stack.ps1
```

## Testing the Implementation

### Test Authentication
```powershell
# Login
curl -X POST http://localhost:8080/api/auth/login `
  -H "Content-Type: application/json" `
  -d '{"username":"admin","password":"admin123"}'

# Response will include JWT token
```

### Test User API
```powershell
# Get all users (requires token)
curl -X GET http://localhost:8080/api/users `
  -H "Authorization: Bearer YOUR_TOKEN_HERE"

# Create user
curl -X POST http://localhost:8080/api/users `
  -H "Authorization: Bearer YOUR_TOKEN_HERE" `
  -H "Content-Type: application/json" `
  -d '{"username":"testuser","firstName":"Test","lastName":"User","email":"test@example.com"}'
```

### Test Frontend

1. Open http://localhost:3000
2. Login with: admin / admin123
3. Navigate to Users page
4. Try creating a new user
5. Try editing/deleting users

## Troubleshooting

### Backend won't start
```powershell
docker logs iam-backend
mvn clean package -DskipTests
```

### Frontend not connecting
```powershell
# Check if API is accessible
curl http://localhost:8080/api/health

# Check browser console for CORS errors
```

### Database connection failed
```powershell
docker-compose logs postgres
docker-compose restart postgres
```

## What's New

✅ **JWT Authentication**
- Real token-based auth
- Login/Register endpoints
- Token validation on every request

✅ **Complete User Service**
- Full CRUD operations
- Search and pagination
- Validation and error handling

✅ **Frontend API Integration**
- Axios client with interceptors
- Token management
- Error handling
- Real-time data loading

## Next Steps

1. Test all CRUD operations
2. Add more users via UI
3. Create groups
4. Implement AD provisioning
5. Add role-based permissions
'@

$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText("QUICK_START.md", $quickStart, $utf8NoBom)

Write-Host "Created QUICK_START.md" -ForegroundColor Green