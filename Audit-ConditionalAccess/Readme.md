# Useful KUSTO queries to audit conditional access

## Default log retention in AAD

To retain Azure Active Directory Audit Logs these are forwarded to a Log Analytics Workspace. With Log Analytics the KUSTO query language can be used to filter audit and activity logs.

* Azure AD Free,  Basic: 7 days
* Azure AD Premium P1 , P2: 30 days

Default Retention: https://docs.microsoft.com/en-us/azure/active-directory/reports-monitoring/reference-reports-data-retention#how-long-does-azure-ad-store-the-data

## Queries

### Monitor CA excluded group changes </font>

The following Azure AD Groups are excluded from all Conditional Access policies (Name, AAD-Object ID):

* ZZ-AS-AccountExcludedFromConditionalAccess

<pre>
AuditLogs
| where  TargetResources[1].id in ('45f6fdde-ee59-4ec5-925b-c02b1fc9a804', '4c6fc6ed-84fb-4c82-9d8f-8d9cff3b3d96') and ActivityDisplayName == "Add member to group"</pre>

### Monitor emergency access administrator sign-ins

<pre>
SigninLogs
| where UserPrincipalName in ('fallbackazureadmin@contoso.onmicrosoft.com', 'azureadmin@contoso.onmicrosoft.com')</pre>

### CA policy modifications

<pre>
AuditLogs | where Category == "Policy"
| summarize count(OperationName) by TimeGenerated, tostring (InitiatedBy.user.userPrincipalName), ActivityDisplayName, tostring(TargetResources[0].displayName)</pre>

### Intune app protection policy modifications (MAM)</font>

<pre>
IntuneAuditLogs
| extend d=parse_json(Properties)
| summarize by Identity, OperationName, tostring(d.TargetDisplayNames)
</pre>
