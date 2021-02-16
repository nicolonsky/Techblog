# Export Applocker Policies for Adjustments

This script exports all OMA-URI settings with the nested XML values as typically used for an applocker policy deployed with Intune.
Encoding is set to UTF-8 to ensure compatibility with special characters commonly used in the German and French language and contained within publisher signatures city names.

1. Ensure that you have the `MSAL.PS` Powershell module installed or install it with: `Install-Module -Name MSAL.PS -Scope CurrentUser`
2. Run the script with dot sourcing: `.\Export-ApplockerPolicy.ps1`
3. When prompted sign-in with your Intune admin account
4. Policies get exported to the same location as the script
5. If you edited the files, **ensure that they have UTF-8 encoding**!
    1. In VS Code you can check the encoding on the right bottom