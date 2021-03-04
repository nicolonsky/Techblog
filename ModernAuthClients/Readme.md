# List of available client apps that support modern authentication

If you block "Exchange ActiveSync clients" & "Other clients" with conditional access to disable legacy protocols (as enabling [Azure AD security defaults](https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/concept-fundamentals-security-defaults#blocking-legacy-authentication) does) there might be some uncertainity about which apps will be still able to access Exchange Online mailboxes and that's why I created this list. Feel free to add more apps and improvements via pull request.

![image](https://user-images.githubusercontent.com/32899754/109959438-c63b5980-7ce7-11eb-93ea-eb17038ff9b5.png)

![image](https://user-images.githubusercontent.com/32899754/109959480-d8b59300-7ce7-11eb-82ab-afa30a3e2267.png)


## Supported apps by platform

### Windows 10

* Microsoft 365 Apps for Business (Outlook 2013 and newer)
* Windows 10 mail app

### macOS

* Microsoft 365 Apps for Business (Outlook 2016 and newer)
* thunderbird

### iOS

* native iOS mail
  * Manual setup select: **sign-in using Microsoft** option
  * When deploying e-mail profile with Intune enable the: **OAuth** setting
* Outlook
* Nine
  * Select: use Microsoft Authenticator as broker

### Android

* Google Mail app
* Outlook
* Nine
  * Select: use Microsoft Authenticator as broker

### linux

* thunderbird

## Further notes
  
* All 3rd party (non-Microsoft) apps come with an initial OAuth app consent request, you might want to add these apps by grant admin consent for all users
 
| iOS | Gmail | thunderbird |
| ----|-------|-------------|
| ![iOS](https://user-images.githubusercontent.com/32899754/110011133-5fd22d80-7d1f-11eb-8302-f460f8822b76.png) | ![Gmail](https://user-images.githubusercontent.com/32899754/110011124-5ea10080-7d1f-11eb-8772-05fc09696e91.png) | ![thunderbird](https://user-images.githubusercontent.com/32899754/110011135-5fd22d80-7d1f-11eb-8d62-e6034ee21d49.png) |

* For thunderbird you need to explicitely select the OAuth option hidden under the "configure manually" option
  * ![image](https://user-images.githubusercontent.com/32899754/110013256-bccee300-7d21-11eb-9b03-7ddf1ab0871a.png)
