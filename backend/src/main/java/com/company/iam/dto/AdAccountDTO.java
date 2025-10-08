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