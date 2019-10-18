$UserCredential = Get-AutomationPSCredential -Name 'EXOCredentials'

Connect-ExchangeOnlineShell -Credential $UserCredential

Get-Mailbox -ResultSize unlimited -RecipientTypeDetails UserMailbox | Foreach-Object {

    Set-MailboxRegionalConfiguration -Identity $PsItem.alias -Language "de-CH" -TimeZone "W. Europe Standard Time" -DateFormat "dd.MM.yyyy"
}

Disconnect-ExchangeOnlineShell
