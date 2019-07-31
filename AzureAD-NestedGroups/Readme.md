# Azure Active Directory nested group support

Azure Active Directory currently has the following limitations regarding nested groups regarding a modern workplace configuration:

| Scenario | Description| Supported |
| ---|---| ---|
| Conditional Access | Targeting Conditional access policies on nested groups and applying them to members | True |
| Self-Service-Password-Reset | Restricting access to SSPR | True |
| Azure AD Join Scope | Restricting Azure AD Device join and registration | True |
| Group based licensing | Apply a group based licensing assignment to nested groups | False |

[Source](https://feedback.azure.com/forums/169401-azure-active-directory/suggestions/15718164-add-support-for-nested-groups-in-azure-ad-app-acc#{toggle_previous_statuses})
