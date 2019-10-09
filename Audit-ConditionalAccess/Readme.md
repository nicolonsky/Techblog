# Useful KUSTO queries to audit conditional access

## Default log retention in AAD

To retain Azure Active Directory Audit Logs these are forwarded to a Log Analytics Workspace. With Log Analytics the KUSTO query language can be used to filter audit and activity logs.

* Azure AD Free,  Basic: 7 days
* Azure AD Premium P1 , P2: 30 days

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

### Intune app protection policy modifications (MAM)</font>

<pre>
IntuneAuditLogs
| extend d=parse_json(Properties)
| summarize by Identity, OperationName, tostring(d.TargetDisplayNames)
</pre>
