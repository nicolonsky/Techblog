
$UserCredential = Get-AutomationPSCredential -Name 'EXOCredentials'

Connect-ExchangeOnlineShell -Credential $UserCredential

Get-Mailbox -ResultSize unlimited -RecipientTypeDetails UserMailbox | Foreach-Object {

   Set-Mailbox mailbox@yourtenant.com -LitigationHoldEnabled $true -LitigationHoldDuration 3650
}

Disconnect-ExchangeOnlineShell