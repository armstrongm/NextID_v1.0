Write-Host "Creating Frontend API Integration..." -ForegroundColor Cyan
Write-Host ""

function Write-FileNoBom {
    param([string]$FilePath, [string]$Content)
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($FilePath, $Content, $utf8NoBom)
}

# Create services directory
if (-not (Test-Path "frontend/src/services")) {
    New-Item -ItemType Directory -Path "frontend/src/services" -Force | Out-Null
}

# API Service
$apiService = @'
import axios from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:8080/api';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add token to requests
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

// Handle response errors
api.interceptors.response.use(
  (response) => response,
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
};

// Groups API
export const groupsAPI = {
  getAll: (params) => api.get('/groups', { params }),
  getById: (id) => api.get(`/groups/${id}`),
  create: (group) => api.post('/groups', group),
  update: (id, group) => api.put(`/groups/${id}`, group),
  delete: (id) => api.delete(`/groups/${id}`),
};

// Connections API
export const connectionsAPI = {
  getAll: () => api.get('/connections'),
  testConnection: (id) => api.post(`/connections/${id}/test`),
  importUsers: (id) => api.post(`/connections/${id}/import-users`),
  create: (connection) => api.post('/connections', connection),
  update: (id, connection) => api.put(`/connections/${id}`, connection),
  delete: (id) => api.delete(`/connections/${id}`),
};

// Provisioning API
export const provisioningAPI = {
  provisionUser: (userId) => api.post(`/provisioning/users/${userId}`),
};

export default api;
'@
Write-FileNoBom -FilePath "frontend/src/services/api.js" -Content $apiService
Write-Host "  ✓ api.js" -ForegroundColor Green

Write-Host ""
Write-Host "====================================" -ForegroundColor Green
Write-Host "API Service Created!" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green