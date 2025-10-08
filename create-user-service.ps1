Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Creating User Service Implementation" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

function Write-FileNoBom {
    param([string]$FilePath, [string]$Content)
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($FilePath, $Content, $utf8NoBom)
}

$basePath = "C:\myNextJsProject\nextID\backend\src\main\java\com\company\iam"

# 1. AuthUser Entity
Write-Host "Creating AuthUser.java..." -ForegroundColor Yellow
$authUser = @'
package com.company.iam.model;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "auth_users")
public class AuthUser {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String username;

    @Column(nullable = false)
    private String passwordHash;

    @Column(unique = true, nullable = false)
    private String email;

    @Enumerated(EnumType.STRING)
    private Role role = Role.USER;

    private Boolean enabled = true;

    @CreationTimestamp
    private LocalDateTime createdAt;

    @UpdateTimestamp
    private LocalDateTime lastLogin;

    public enum Role {
        USER, ADMIN, SUPERADMIN
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public Role getRole() { return role; }
    public void setRole(Role role) { this.role = role; }

    public Boolean getEnabled() { return enabled; }
    public void setEnabled(Boolean enabled) { this.enabled = enabled; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getLastLogin() { return lastLogin; }
    public void setLastLogin(LocalDateTime lastLogin) { this.lastLogin = lastLogin; }
}
'@
Write-FileNoBom -FilePath "$basePath/model/AuthUser.java" -Content $authUser
Write-Host "  ✓ Created" -ForegroundColor Green

# 2. User Entity
Write-Host "Creating User.java..." -ForegroundColor Yellow
$user = @'
package com.company.iam.model;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String username;

    private String firstName;
    private String lastName;

    @Column(unique = true, nullable = false)
    private String email;

    @Enumerated(EnumType.STRING)
    private UserStatus status = UserStatus.PENDING;

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<AdAccount> adAccounts = new ArrayList<>();

    @ManyToMany
    @JoinTable(
        name = "group_membership",
        joinColumns = @JoinColumn(name = "user_id"),
        inverseJoinColumns = @JoinColumn(name = "group_id")
    )
    private Set<Group> groups = new HashSet<>();

    @CreationTimestamp
    private LocalDateTime createdAt;

    @UpdateTimestamp
    private LocalDateTime updatedAt;

    public enum UserStatus {
        PENDING, ACTIVE, INACTIVE, SUSPENDED
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

    public UserStatus getStatus() { return status; }
    public void setStatus(UserStatus status) { this.status = status; }

    public List<AdAccount> getAdAccounts() { return adAccounts; }
    public void setAdAccounts(List<AdAccount> adAccounts) { this.adAccounts = adAccounts; }

    public Set<Group> getGroups() { return groups; }
    public void setGroups(Set<Group> groups) { this.groups = groups; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public boolean isProvisioned() {
        return adAccounts != null && !adAccounts.isEmpty();
    }
}
'@
Write-FileNoBom -FilePath "$basePath/model/User.java" -Content $user
Write-Host "  ✓ Created" -ForegroundColor Green

# 3. Group Entity
Write-Host "Creating Group.java..." -ForegroundColor Yellow
$group = @'
package com.company.iam.model;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "groups")
public class Group {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String name;

    private String description;

    @ManyToMany(mappedBy = "groups")
    private Set<User> members = new HashSet<>();

    @CreationTimestamp
    private LocalDateTime createdAt;

    @UpdateTimestamp
    private LocalDateTime updatedAt;

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Set<User> getMembers() { return members; }
    public void setMembers(Set<User> members) { this.members = members; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public int getMemberCount() {
        return members != null ? members.size() : 0;
    }
}
'@
Write-FileNoBom -FilePath "$basePath/model/Group.java" -Content $group
Write-Host "  ✓ Created" -ForegroundColor Green

# 4. AdAccount Entity
Write-Host "Creating AdAccount.java..." -ForegroundColor Yellow
$adAccount = @'
package com.company.iam.model;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "ad_accounts")
public class AdAccount {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false)
    private String samAccountName;

    @Column(nullable = false)
    private String distinguishedName;

    private String userPrincipalName;

    @Column(unique = true)
    private String adGuid;

    @Enumerated(EnumType.STRING)
    private AdAccountStatus status = AdAccountStatus.ACTIVE;

    private String lastError;
    private Boolean retryRequired = false;

    @CreationTimestamp
    private LocalDateTime provisionedAt;

    @UpdateTimestamp
    private LocalDateTime lastSyncedAt;

    public enum AdAccountStatus {
        ACTIVE, INACTIVE, FAILED
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }

    public String getSamAccountName() { return samAccountName; }
    public void setSamAccountName(String samAccountName) { this.samAccountName = samAccountName; }

    public String getDistinguishedName() { return distinguishedName; }
    public void setDistinguishedName(String distinguishedName) { this.distinguishedName = distinguishedName; }

    public String getUserPrincipalName() { return userPrincipalName; }
    public void setUserPrincipalName(String userPrincipalName) { this.userPrincipalName = userPrincipalName; }

    public String getAdGuid() { return adGuid; }
    public void setAdGuid(String adGuid) { this.adGuid = adGuid; }

    public AdAccountStatus getStatus() { return status; }
    public void setStatus(AdAccountStatus status) { this.status = status; }

    public String getLastError() { return lastError; }
    public void setLastError(String lastError) { this.lastError = lastError; }

    public Boolean getRetryRequired() { return retryRequired; }
    public void setRetryRequired(Boolean retryRequired) { this.retryRequired = retryRequired; }

    public LocalDateTime getProvisionedAt() { return provisionedAt; }
    public void setProvisionedAt(LocalDateTime provisionedAt) { this.provisionedAt = provisionedAt; }

    public LocalDateTime getLastSyncedAt() { return lastSyncedAt; }
    public void setLastSyncedAt(LocalDateTime lastSyncedAt) { this.lastSyncedAt = lastSyncedAt; }
}
'@
Write-FileNoBom -FilePath "$basePath/model/AdAccount.java" -Content $adAccount
Write-Host "  ✓ Created" -ForegroundColor Green

# 5. Repositories
Write-Host "Creating Repositories..." -ForegroundColor Yellow

$authUserRepo = @'
package com.company.iam.repository;

import com.company.iam.model.AuthUser;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface AuthUserRepository extends JpaRepository<AuthUser, Long> {
    Optional<AuthUser> findByUsername(String username);
    Optional<AuthUser> findByEmail(String email);
    boolean existsByUsername(String username);
    boolean existsByEmail(String email);
}
'@
Write-FileNoBom -FilePath "$basePath/repository/AuthUserRepository.java" -Content $authUserRepo

$userRepo = @'
package com.company.iam.repository;

import com.company.iam.model.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByUsername(String username);
    Optional<User> findByEmail(String email);
    boolean existsByUsername(String username);
    boolean existsByEmail(String email);
    
    @Query("SELECT u FROM User u WHERE " +
           "LOWER(u.username) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(u.email) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(u.firstName) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(u.lastName) LIKE LOWER(CONCAT('%', :search, '%'))")
    Page<User> searchUsers(@Param("search") String search, Pageable pageable);
}
'@
Write-FileNoBom -FilePath "$basePath/repository/UserRepository.java" -Content $userRepo

$groupRepo = @'
package com.company.iam.repository;

import com.company.iam.model.Group;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface GroupRepository extends JpaRepository<Group, Long> {
    Optional<Group> findByName(String name);
    boolean existsByName(String name);
    
    @Query("SELECT g FROM Group g WHERE " +
           "LOWER(g.name) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(g.description) LIKE LOWER(CONCAT('%', :search, '%'))")
    Page<Group> searchGroups(@Param("search") String search, Pageable pageable);
}
'@
Write-FileNoBom -FilePath "$basePath/repository/GroupRepository.java" -Content $groupRepo

Write-Host "  ✓ Created Repositories" -ForegroundColor Green

Write-Host ""
Write-Host "User Service Models Created!" -ForegroundColor Green