Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Creating Frontend API Integration" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

function Write-FileNoBom {
    param([string]$FilePath, [string]$Content)
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($FilePath, $Content, $utf8NoBom)
}

# Create services directory
if (-not (Test-Path "C:\myNextJsProject\nextID\frontend\src\services")) {
    New-Item -ItemType Directory -Path "C:\myNextJsProject\nextID\frontend\src\services" -Force | Out-Null
}

# 1. api.js - API client configuration
Write-Host "Creating api.js..." -ForegroundColor Yellow
$apiJs = @'
import axios from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:8080/api';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor - Add token to requests
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor - Handle errors
api.interceptors.response.use(
  (response) => {
    return response;
  },
  (error) => {
    if (error.response?.status === 401) {
      // Token expired or invalid
      localStorage.removeItem('token');
      localStorage.removeItem('user');
      window.location.href = '/';
    }
    return Promise.reject(error);
  }
);

// Auth API
export const authAPI = {
  login: (credentials) => api.post('/auth/login', credentials),
  register: (userData) => api.post('/auth/register', userData),
  getCurrentUser: () => api.get('/auth/me'),
};

// Users API
export const usersAPI = {
  getAll: (params) => api.get('/users', { params }),
  getById: (id) => api.get(`/users/${id}`),
  create: (user) => api.post('/users', user),
  update: (id, user) => api.put(`/users/${id}`, user),
  delete: (id) => api.delete(`/users/${id}`),
  getStats: () => api.get('/users/stats'),
};

// Groups API
export const groupsAPI = {
  getAll: (params) => api.get('/groups', { params }),
  getById: (id) => api.get(`/groups/${id}`),
  create: (group) => api.post('/groups', group),
  update: (id, group) => api.put(`/groups/${id}`, group),
  delete: (id) => api.delete(`/groups/${id}`),
  getStats: () => api.get('/groups/stats'),
};

export default api;
'@
Write-FileNoBom -FilePath "C:\myNextJsProject\nextID\frontend\src\services\api.js" -Content $apiJs
Write-Host "  ✓ Created" -ForegroundColor Green

# 2. Create .env for frontend
Write-Host "Creating frontend .env..." -ForegroundColor Yellow
$frontendEnv = @'
REACT_APP_API_URL=http://localhost:8080/api
'@
Write-FileNoBom -FilePath "C:\myNextJsProject\nextID\frontend\.env" -Content $frontendEnv
Write-Host "  ✓ Created" -ForegroundColor Green

Write-Host ""
Write-Host "Frontend API Integration Created!" -ForegroundColor Green