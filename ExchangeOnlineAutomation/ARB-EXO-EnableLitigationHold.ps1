
$UserCredential = Get-AutomationPSCredential -Name 'EXOCredentials'

Connect-ExchangeOnlineShell -Credential $UserCredential

Get-Mailbox -ResultSize unlimited -RecipientTypeDetails UserMailbox | Foreach-Object {

   Set-Mailbox -Identity $PsItem.alias -LitigationHoldEnabled $true -LitigationHoldDuration 3650
}

Disconnect-ExchangeOnlineShell
