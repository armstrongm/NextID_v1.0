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