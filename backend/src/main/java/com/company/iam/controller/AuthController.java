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