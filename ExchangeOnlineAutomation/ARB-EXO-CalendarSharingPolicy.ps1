$localizations = @()

$localizations += [PSCustomObject]@{
    code = "en"
    localization = "Calendar"
}

$localizations += [PSCustomObject]@{
    code = "de"
    localization = "Kalender"
}

# Specify desired default access rights for everyone in organization
# Fulldocumentation: https://docs.microsoft.com/en-us/powershell/module/exchange/mailboxes/set-mailboxfolderpermission?view=exchange-ps#parameters

$calendarAccessRights= "LimitedDetails"

$UserCredential = Get-AutomationPSCredential -Name 'EXOCredentials'

Connect-ExchangeOnlineShell -Credential $UserCredential

Get-Mailbox -ResultSize unlimited -RecipientTypeDetails UserMailbox | Foreach-Object {

    $currentLanguage = Get-MailboxRegionalConfiguration -Identity $PsItem.alias

    $calendarNameLocalized= $localizations | Where-Object -Property code -Match $(([string]$currentLanguage.Language).Split("-")[0]) | Select-Object -ExpandProperty localization
           
    Write-Output "Translated calendar name: $($PsItem.alias):\$calendarNameLocalized"

    Set-MailboxFolderPermission -Identity "$($PsItem.alias):\$calendarNameLocalized" -User Default -AccessRights $calendarAccessRights -Verbose

}

Disconnect-ExchangeOnlineShell