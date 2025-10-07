Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Creating Java Source Files (No BOM)" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# Function to write file without BOM
function Write-FileNoBom {
    param(
        [string]$FilePath,
        [string]$Content
    )
    
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($FilePath, $Content, $utf8NoBom)
}

# Ensure directories exist
$basePath = "C:\myNextJsProject\nextID\backend\src\main\java\com\company\iam"
$dirs = @(
    "$basePath",
    "$basePath/config",
    "$basePath/controller",
    "$basePath/service",
    "$basePath/repository",
    "$basePath/model",
    "$basePath/dto",
    "$basePath/exception",
    "$basePath/security"
)

foreach ($dir in $dirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "Created directory: $dir" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Creating Java source files..." -ForegroundColor Yellow
Write-Host ""

# 1. Main Application Class
$mainApp = @"
package com.company.iam;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

@SpringBootApplication
@EnableJpaAuditing
public class IamApplication {
    public static void main(String[] args) {
        SpringApplication.run(IamApplication.class, args);
    }
}
"@
Write-FileNoBom -FilePath "$basePath/IamApplication.java" -Content $mainApp
Write-Host "Created: IamApplication.java" -ForegroundColor Green

# 2. Security Configuration
$securityConfig = @"
package com.company.iam.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/auth/**", "/api/actuator/health", "/api/health").permitAll()
                .anyRequest().authenticated()
            )
            .sessionManagement(session -> session
                .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            );
        
        return http.build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOrigins(Arrays.asList("http://localhost:3000", "http://localhost:80"));
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(Arrays.asList("*"));
        configuration.setAllowCredentials(true);
        
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }
}
"@
Write-FileNoBom -FilePath "$basePath/config/SecurityConfig.java" -Content $securityConfig
Write-Host "Created: SecurityConfig.java" -ForegroundColor Green

# 3. Health Controller
$healthController = @"
package com.company.iam.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.CrossOrigin;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class HealthController {

    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> health() {
        Map<String, String> response = new HashMap<>();
        response.put("status", "UP");
        response.put("application", "IAM Service");
        return ResponseEntity.ok(response);
    }
}
"@
Write-FileNoBom -FilePath "$basePath/controller/HealthController.java" -Content $healthController
Write-Host "Created: HealthController.java" -ForegroundColor Green

# 4. Auth Controller
$authController = @"
package com.company.iam.controller;

import com.company.iam.dto.LoginRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    @PostMapping("/login")
    public ResponseEntity<Map<String, Object>> login(@RequestBody LoginRequest request) {
        Map<String, Object> response = new HashMap<>();
        
        if ("admin".equals(request.getUsername()) && "admin123".equals(request.getPassword())) {
            response.put("token", "demo-jwt-token-12345");
            response.put("username", "admin");
            response.put("email", "admin@company.com");
            response.put("role", "ADMIN");
            return ResponseEntity.ok(response);
        }
        
        return ResponseEntity.status(401).body(Map.of("error", "Invalid credentials"));
    }

    @PostMapping("/register")
    public ResponseEntity<Map<String, Object>> register(@RequestBody Map<String, String> request) {
        Map<String, Object> response = new HashMap<>();
        response.put("token", "demo-jwt-token-67890");
        response.put("username", request.get("username"));
        response.put("email", request.get("email"));
        response.put("role", "USER");
        return ResponseEntity.ok(response);
    }

    @GetMapping("/me")
    public ResponseEntity<Map<String, String>> getCurrentUser() {
        Map<String, String> response = new HashMap<>();
        response.put("username", "admin");
        response.put("email", "admin@company.com");
        response.put("role", "ADMIN");
        return ResponseEntity.ok(response);
    }
}
"@
Write-FileNoBom -FilePath "$basePath/controller/AuthController.java" -Content $authController
Write-Host "Created: AuthController.java" -ForegroundColor Green

# 5. LoginRequest DTO
$loginRequest = @"
package com.company.iam.dto;

public class LoginRequest {
    private String username;
    private String password;

    public LoginRequest() {
    }

    public LoginRequest(String username, String password) {
        this.username = username;
        this.password = password;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}
"@
Write-FileNoBom -FilePath "$basePath/dto/LoginRequest.java" -Content $loginRequest
Write-Host "Created: LoginRequest.java" -ForegroundColor Green

# 6. Exception Handler
$exceptionHandler = @"
package com.company.iam.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.HashMap;
import java.util.Map;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, String>> handleException(Exception ex) {
        Map<String, String> error = new HashMap<>();
        error.put("error", ex.getMessage());
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
    }
}
"@
Write-FileNoBom -FilePath "$basePath/exception/GlobalExceptionHandler.java" -Content $exceptionHandler
Write-Host "Created: GlobalExceptionHandler.java" -ForegroundColor Green

# 7. Create application.yml
$appYml = @"
spring:
  application:
    name: iam-service
  datasource:
    url: jdbc:postgresql://postgres:5432/`${DB_NAME:iam_db}
    username: `${DB_USER:iam_user}
    password: `${DB_PASSWORD}
  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: false
  flyway:
    enabled: true
    baseline-on-migrate: true

server:
  port: 8080

management:
  endpoints:
    web:
      exposure:
        include: health,info
  endpoint:
    health:
      show-details: when-authorized

logging:
  level:
    com.company.iam: INFO
"@
$resourcesPath = "C:\myNextJsProject\nextID\backend\src\main\resources"
if (-not (Test-Path $resourcesPath)) {
    New-Item -ItemType Directory -Path $resourcesPath -Force | Out-Null
}
Write-FileNoBom -FilePath "$resourcesPath/application.yml" -Content $appYml
Write-Host "Created: application.yml" -ForegroundColor Green

Write-Host ""
Write-Host "====================================" -ForegroundColor Green
Write-Host "Java Source Files Created!" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green
Write-Host ""
Write-Host "Testing compilation..." -ForegroundColor Yellow

Push-Location backend
mvn clean compile
$exitCode = $LASTEXITCODE
Pop-Location

if ($exitCode -eq 0) {
    Write-Host ""
    Write-Host "Compilation successful!" -ForegroundColor Green
    Write-Host "You can now run: .\build.ps1" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "Compilation failed. Check the output above." -ForegroundColor Red
}