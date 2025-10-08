Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Creating Service Implementations" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

function Write-FileNoBom {
    param([string]$FilePath, [string]$Content)
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($FilePath, $Content, $utf8NoBom)
}

$basePath = "C:\myNextJsProject\nextID\backend\src\main\java\com\company\iam"

# 1. AuthenticationService
Write-Host "Creating AuthenticationService.java..." -ForegroundColor Yellow
$authService = @'
package com.company.iam.service;

import com.company.iam.dto.AuthResponse;
import com.company.iam.dto.LoginRequest;
import com.company.iam.dto.RegisterRequest;
import com.company.iam.model.AuthUser;
import com.company.iam.repository.AuthUserRepository;
import com.company.iam.security.JwtService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
public class AuthenticationService {

    @Autowired
    private AuthUserRepository authUserRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtService jwtService;

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private CustomUserDetailsService userDetailsService;

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        // Check if username already exists
        if (authUserRepository.existsByUsername(request.getUsername())) {
            throw new RuntimeException("Username already exists");
        }

        // Check if email already exists
        if (authUserRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email already registered");
        }

        // Create new user
        AuthUser user = new AuthUser();
        user.setUsername(request.getUsername());
        user.setEmail(request.getEmail());
        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        user.setRole(AuthUser.Role.USER);
        user.setEnabled(true);

        authUserRepository.save(user);

        // Generate token
        UserDetails userDetails = userDetailsService.loadUserByUsername(user.getUsername());
        String token = jwtService.generateToken(userDetails);

        return new AuthResponse(
            token,
            user.getUsername(),
            user.getEmail(),
            user.getRole().name()
        );
    }

    @Transactional
    public AuthResponse authenticate(LoginRequest request) {
        // Authenticate user
        authenticationManager.authenticate(
            new UsernamePasswordAuthenticationToken(
                request.getUsername(),
                request.getPassword()
            )
        );

        // Get user details
        AuthUser user = authUserRepository.findByUsername(request.getUsername())
            .orElseThrow(() -> new RuntimeException("User not found"));

        // Update last login
        user.setLastLogin(LocalDateTime.now());
        authUserRepository.save(user);

        // Generate token
        UserDetails userDetails = userDetailsService.loadUserByUsername(user.getUsername());
        String token = jwtService.generateToken(userDetails);

        return new AuthResponse(
            token,
            user.getUsername(),
            user.getEmail(),
            user.getRole().name()
        );
    }

    public AuthUser getCurrentUser(String username) {
        return authUserRepository.findByUsername(username)
            .orElseThrow(() -> new RuntimeException("User not found"));
    }
}
'@
Write-FileNoBom -FilePath "$basePath/service/AuthenticationService.java" -Content $authService
Write-Host "  ✓ Created" -ForegroundColor Green

# 2. UserService
Write-Host "Creating UserService.java..." -ForegroundColor Yellow
$userService = @'
package com.company.iam.service;

import com.company.iam.dto.UserDTO;
import com.company.iam.model.User;
import com.company.iam.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    public Page<UserDTO> findAll(String search, Pageable pageable) {
        Page<User> users;
        
        if (search != null && !search.trim().isEmpty()) {
            users = userRepository.searchUsers(search.trim(), pageable);
        } else {
            users = userRepository.findAll(pageable);
        }
        
        return users.map(UserDTO::fromEntity);
    }

    public UserDTO findById(Long id) {
        User user = userRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("User not found with id: " + id));
        return UserDTO.fromEntity(user);
    }

    @Transactional
    public UserDTO create(UserDTO userDTO) {
        // Check if username already exists
        if (userRepository.existsByUsername(userDTO.getUsername())) {
            throw new RuntimeException("Username already exists");
        }

        // Check if email already exists
        if (userRepository.existsByEmail(userDTO.getEmail())) {
            throw new RuntimeException("Email already exists");
        }

        User user = new User();
        user.setUsername(userDTO.getUsername());
        user.setFirstName(userDTO.getFirstName());
        user.setLastName(userDTO.getLastName());
        user.setEmail(userDTO.getEmail());
        user.setStatus(User.UserStatus.PENDING);

        User savedUser = userRepository.save(user);
        return UserDTO.fromEntity(savedUser);
    }

    @Transactional
    public UserDTO update(Long id, UserDTO userDTO) {
        User user = userRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("User not found with id: " + id));

        // Check if username is being changed and if it already exists
        if (!user.getUsername().equals(userDTO.getUsername()) && 
            userRepository.existsByUsername(userDTO.getUsername())) {
            throw new RuntimeException("Username already exists");
        }

        // Check if email is being changed and if it already exists
        if (!user.getEmail().equals(userDTO.getEmail()) && 
            userRepository.existsByEmail(userDTO.getEmail())) {
            throw new RuntimeException("Email already exists");
        }

        user.setUsername(userDTO.getUsername());
        user.setFirstName(userDTO.getFirstName());
        user.setLastName(userDTO.getLastName());
        user.setEmail(userDTO.getEmail());
        
        if (userDTO.getStatus() != null) {
            user.setStatus(User.UserStatus.valueOf(userDTO.getStatus()));
        }

        User updatedUser = userRepository.save(user);
        return UserDTO.fromEntity(updatedUser);
    }

    @Transactional
    public void delete(Long id) {
        if (!userRepository.existsById(id)) {
            throw new RuntimeException("User not found with id: " + id);
        }
        userRepository.deleteById(id);
    }

    public long count() {
        return userRepository.count();
    }

    public long countProvisioned() {
        return userRepository.findAll().stream()
            .filter(User::isProvisioned)
            .count();
    }
}
'@
Write-FileNoBom -FilePath "$basePath/service/UserService.java" -Content $userService
Write-Host "  ✓ Created" -ForegroundColor Green

# 3. GroupService
Write-Host "Creating GroupService.java..." -ForegroundColor Yellow
$groupService = @'
package com.company.iam.service;

import com.company.iam.dto.GroupDTO;
import com.company.iam.model.Group;
import com.company.iam.repository.GroupRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class GroupService {

    @Autowired
    private GroupRepository groupRepository;

    public Page<GroupDTO> findAll(String search, Pageable pageable) {
        Page<Group> groups;
        
        if (search != null && !search.trim().isEmpty()) {
            groups = groupRepository.searchGroups(search.trim(), pageable);
        } else {
            groups = groupRepository.findAll(pageable);
        }
        
        return groups.map(GroupDTO::fromEntity);
    }

    public GroupDTO findById(Long id) {
        Group group = groupRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Group not found with id: " + id));
        return GroupDTO.fromEntity(group);
    }

    @Transactional
    public GroupDTO create(GroupDTO groupDTO) {
        if (groupRepository.existsByName(groupDTO.getName())) {
            throw new RuntimeException("Group name already exists");
        }

        Group group = new Group();
        group.setName(groupDTO.getName());
        group.setDescription(groupDTO.getDescription());

        Group savedGroup = groupRepository.save(group);
        return GroupDTO.fromEntity(savedGroup);
    }

    @Transactional
    public GroupDTO update(Long id, GroupDTO groupDTO) {
        Group group = groupRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Group not found with id: " + id));

        if (!group.getName().equals(groupDTO.getName()) && 
            groupRepository.existsByName(groupDTO.getName())) {
            throw new RuntimeException("Group name already exists");
        }

        group.setName(groupDTO.getName());
        group.setDescription(groupDTO.getDescription());

        Group updatedGroup = groupRepository.save(group);
        return GroupDTO.fromEntity(updatedGroup);
    }

    @Transactional
    public void delete(Long id) {
        if (!groupRepository.existsById(id)) {
            throw new RuntimeException("Group not found with id: " + id);
        }
        groupRepository.deleteById(id);
    }

    public long count() {
        return groupRepository.count();
    }
}
'@
Write-FileNoBom -FilePath "$basePath/service/GroupService.java" -Content $groupService
Write-Host "  ✓ Created" -ForegroundColor Green

Write-Host ""
Write-Host "Service Implementations Created!" -ForegroundColor Green