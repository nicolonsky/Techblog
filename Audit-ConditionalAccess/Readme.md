# Useful KUSTO queries to audit conditional access

[A full blogpost and more details are available on my blog](https://tech.nicolonsky.ch/conditional-access-and-azure-log-analytics-in-harmony/). If you are only looking for the KUSTO queries better stay here.

## Default log retention in AAD

Azure Active Directory stores all activity reports depending on your license for 7  or 30 days:

* Azure AD Free and Basic: 7 days
* Azure AD Premium P1  and P2: 30 days

Default Retention: https://docs.microsoft.com/en-us/azure/active-directory/reports-monitoring/reference-reports-data-retention#how-long-does-azure-ad-store-the-data

## Queries

### Monitor CA excluded group changes

The following Azure AD Groups are excluded from all Conditional Access policies (Name, AAD-Object ID):

* GS-AccountsExcludedFromConditionalAccess, 657085c0-0608-4b31-95e9-9925f83caa54

<pre>
AuditLogs
| where  TargetResources[1].id in ('657085c0-0608-4b31-95e9-9925f83caa54') and ActivityDisplayName == "Add member to group"
| project  ActivityDateTime, ActivityDisplayName , TargetResources[0].userPrincipalName, InitiatedBy.user.userPrincipalName</pre>

### Monitor emergency access administrator sign-ins

<pre>
SigninLogs
| where UserPrincipalName in ('fallbackazureadmin@contoso.onmicrosoft.com', 'azureadmin@contoso.onmicrosoft.com')</pre>

### CA policy modifications

<pre>
AuditLogs
| where Category == "Policy"
| project  ActivityDateTime, ActivityDisplayName , TargetResources[0].displayName, InitiatedBy.user.userPrincipalName</pre>

### Changes on accounts

Find modifications on sensitive accounts like a password reset or security info reset:

<pre>
AuditLogs
| where OperationName == "Update user" and TargetResources[0].userPrincipalName in ("test.nicola@nicolonsky.ch")
| project TimeGenerated, InitiatedBy.user.userPrincipalName, TargetResources[0].userPrincipalName, TargetResources[0].modifiedProperties
</pre>

### Intune app protection policy modifications (MAM)</font>

<pre>
IntuneAuditLogs
| extend d=parse_json(Properties)
| summarize by Identity, OperationName, tostring(d.TargetDisplayNames)
</pre>
