# List of available client apps that support modern authentication

If you block "Exchange ActiveSync clients" & "Other clients" with conditional access to enforce modern authentication and disable all legacy clients there might be some uncertainity which apps still can access Exchange Online mailboxes and that's why I created this list. Feel free to add more apps via pull request.

![image](https://user-images.githubusercontent.com/32899754/109959438-c63b5980-7ce7-11eb-93ea-eb17038ff9b5.png)

![image](https://user-images.githubusercontent.com/32899754/109959480-d8b59300-7ce7-11eb-82ab-afa30a3e2267.png)


## Windows 10

* Microsoft 365 Apps for Business (Outlook 2013 and newer)
* Windows 10 mail app
* Thunderbird with OAuth manually configured

## macOS

* Microsoft 365 Apps for Business (Outlook 2016 and newer)

## iOS

* native iOS mail
  * Manual setup select: **sign-in using Microsoft** option
  * When deploying e-mail profile with Intune enable the: **OAuth** setting
* Outlook
* Nine
  * Select: use Microsoft Authenticator as broker

## Android

* Google Mail app
* Outlook
* Nine
  * Select: use Microsoft Authenticator as broker

## linux

* Thunderbird with OAuth manually configured (I did not test this yet)

