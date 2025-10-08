Write-Host "Creating DTOs and Services..." -ForegroundColor Cyan
Write-Host ""

function Write-FileNoBom {
    param([string]$FilePath, [string]$Content)
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($FilePath, $Content, $utf8NoBom)
}

$basePath = "C:\myNextJsProject\nextID\backend\src\main\java\com\company\iam"

# 1. UserDTO
Write-Host "Creating UserDTO.java..." -ForegroundColor Yellow
$userDto = @'
package com.company.iam.dto;

import com.company.iam.model.User;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

public class UserDTO {
    private Long id;
    private String username;
    private String firstName;
    private String lastName;
    private String email;
    private String status;
    private boolean provisioned;
    private List<AdAccountDTO> accounts;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public static UserDTO fromEntity(User user) {
        UserDTO dto = new UserDTO();
        dto.setId(user.getId());
        dto.setUsername(user.getUsername());
        dto.setFirstName(user.getFirstName());
        dto.setLastName(user.getLastName());
        dto.setEmail(user.getEmail());
        dto.setStatus(user.getStatus().name());
        dto.setProvisioned(user.isProvisioned());
        dto.setCreatedAt(user.getCreatedAt());
        dto.setUpdatedAt(user.getUpdatedAt());
        
        if (user.getAdAccounts() != null) {
            dto.setAccounts(user.getAdAccounts().stream()
                .map(AdAccountDTO::fromEntity)
                .collect(Collectors.toList()));
        }
        
        return dto;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }

    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public boolean isProvisioned() { return provisioned; }
    public void setProvisioned(boolean provisioned) { this.provisioned = provisioned; }

    public List<AdAccountDTO> getAccounts() { return accounts; }
    public void setAccounts(List<AdAccountDTO> accounts) { this.accounts = accounts; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
'@
Write-FileNoBom -FilePath "$basePath/dto/UserDTO.java" -Content $userDto
Write-Host "  ✓ Created" -ForegroundColor Green

# 2. AdAccountDTO
$adAccountDto = @'
package com.company.iam.dto;

import com.company.iam.model.AdAccount;
import java.time.LocalDateTime;

public class AdAccountDTO {
    private Long id;
    private String samAccountName;
    private String distinguishedName;
    private String userPrincipalName;
    private String adGuid;
    private String status;
    private LocalDateTime provisionedAt;

    public static AdAccountDTO fromEntity(AdAccount account) {
        AdAccountDTO dto = new AdAccountDTO();
        dto.setId(account.getId());
        dto.setSamAccountName(account.getSamAccountName());
        dto.setDistinguishedName(account.getDistinguishedName());
        dto.setUserPrincipalName(account.getUserPrincipalName());
        dto.setAdGuid(account.getAdGuid());
        dto.setStatus(account.getStatus().name());
        dto.setProvisionedAt(account.getProvisionedAt());
        return dto;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getSamAccountName() { return samAccountName; }
    public void setSamAccountName(String samAccountName) { this.samAccountName = samAccountName; }

    public String getDistinguishedName() { return distinguishedName; }
    public void setDistinguishedName(String distinguishedName) { this.distinguishedName = distinguishedName; }

    public String getUserPrincipalName() { return userPrincipalName; }
    public void setUserPrincipalName(String userPrincipalName) { this.userPrincipalName = userPrincipalName; }

    public String getAdGuid() { return adGuid; }
    public void setAdGuid(String adGuid) { this.adGuid = adGuid; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getProvisionedAt() { return provisionedAt; }
    public void setProvisionedAt(LocalDateTime provisionedAt) { this.provisionedAt = provisionedAt; }
}
'@
Write-FileNoBom -FilePath "$basePath/dto/AdAccountDTO.java" -Content $adAccountDto

# 3. GroupDTO
$groupDto = @'
package com.company.iam.dto;

import com.company.iam.model.Group;
import java.time.LocalDateTime;

public class GroupDTO {
    private Long id;
    private String name;
    private String description;
    private int memberCount;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public static GroupDTO fromEntity(Group group) {
        GroupDTO dto = new GroupDTO();
        dto.setId(group.getId());
        dto.setName(group.getName());
        dto.setDescription(group.getDescription());
        dto.setMemberCount(group.getMemberCount());
        dto.setCreatedAt(group.getCreatedAt());
        dto.setUpdatedAt(group.getUpdatedAt());
        return dto;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public int getMemberCount() { return memberCount; }
    public void setMemberCount(int memberCount) { this.memberCount = memberCount; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
'@
Write-FileNoBom -FilePath "$basePath/dto/GroupDTO.java" -Content $groupDto

# 4. AuthResponse
$authResponse = @'
package com.company.iam.dto;

public class AuthResponse {
    private String token;
    private String username;
    private String email;
    private String role;

    public AuthResponse(String token, String username, String email, String role) {
        this.token = token;
        this.username = username;
        this.email = email;
        this.role = role;
    }

    // Getters and Setters
    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
}
'@
Write-FileNoBom -FilePath "$basePath/dto/AuthResponse.java" -Content $authResponse

# 5. RegisterRequest
$registerRequest = @'
package com.company.iam.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class RegisterRequest {
    
    @NotBlank(message = "Username is required")
    @Size(min = 3, max = 50, message = "Username must be between 3 and 50 characters")
    private String username;

    @NotBlank(message = "Email is required")
    @Email(message = "Email should be valid")
    private String email;

    @NotBlank(message = "Password is required")
    @Size(min = 6, message = "Password must be at least 6 characters")
    private String password;

    // Getters and Setters
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
}
'@
Write-FileNoBom -FilePath "$basePath/dto/RegisterRequest.java" -Content $registerRequest

Write-Host "  ✓ Created DTOs" -ForegroundColor Green

# 6. CustomUserDetailsService
Write-Host "Creating CustomUserDetailsService.java..." -ForegroundColor Yellow
$userDetailsService = @'
package com.company.iam.service;

import com.company.iam.model.AuthUser;
import com.company.iam.repository.AuthUserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.Collections;

@Service
public class CustomUserDetailsService implements UserDetailsService {

    @Autowired
    private AuthUserRepository authUserRepository;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        AuthUser user = authUserRepository.findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException("User not found: " + username));

        return org.springframework.security.core.userdetails.User.builder()
                .username(user.getUsername())
                .password(user.getPasswordHash())
                .authorities(Collections.singletonList(
                    new SimpleGrantedAuthority("ROLE_" + user.getRole().name())
                ))
                .accountExpired(false)
                .accountLocked(!user.getEnabled())
                .credentialsExpired(false)
                .disabled(!user.getEnabled())
                .build();
    }
}
'@
Write-FileNoBom -FilePath "$basePath/service/CustomUserDetailsService.java" -Content $userDetailsService
Write-Host "  ✓ Created" -ForegroundColor Green

Write-Host ""
Write-Host "DTOs and Services Created!" -ForegroundColor Green