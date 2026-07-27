# Target : 10.129.25.69

# Scan nmap
## Port Discorvery

```js
    ~/Téléchargements/CHall ❯ nmap 10.129.25.69                                                             00:06:45
Starting Nmap 7.99 ( https://nmap.org ) at 2026-06-28 00:06 +0000
Nmap scan report for 10.129.25.69
Host is up (0.32s latency).
Not shown: 992 closed tcp ports (reset)
PORT     STATE SERVICE
22/tcp   open  ssh
80/tcp   open  http
110/tcp  open  pop3
111/tcp  open  rpcbind
143/tcp  open  imap
993/tcp  open  imaps
995/tcp  open  pop3s
2049/tcp open  nfs

Nmap done: 1 IP address (1 host up) scanned in 5.20 seconds

```

## Full Scan and Services Version

```js
    ~/Téléchargements/CHall ❯ nmap -sV -sC 10.129.25.69                        
22/tcp   open  ssh      OpenSSH 9.6p1 Ubuntu 3ubuntu13.16 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   256 0c:4b:d2:76:ab:10:06:92:05:dc:f7:55:94:7f:18:df (ECDSA)
|_  256 2d:6d:4a:4c:ee:2e:11:b6:c8:90:e6:83:e9:df:38:b0 (ED25519)
80/tcp   open  http     nginx 1.24.0 (Ubuntu)
|_http-server-header: nginx/1.24.0 (Ubuntu)
|_http-title: Enigma Corp \xE2\x80\x94 Managed IT Solutions
110/tcp  open  pop3     Dovecot pop3d
|_pop3-capabilities: TOP SASL STLS PIPELINING RESP-CODES UIDL CAPA AUTH-RESP-CODE
| ssl-cert: Subject: commonName=enigma
| Subject Alternative Name: DNS:enigma
| Not valid before: 2026-02-18T20:33:33
|_Not valid after:  2036-02-16T20:33:33
|_ssl-date: TLS randomness does not represent time
111/tcp  open  rpcbind  2-4 (RPC #100000)
| rpcinfo: 
|   program version    port/proto  service
|   100003  3,4         2049/tcp   nfs
|   100003  3,4         2049/tcp6  nfs
|   100005  1,2,3      35177/tcp6  mountd
|   100005  1,2,3      48861/udp6  mountd
|   100005  1,2,3      48894/udp   mountd
|_  100005  1,2,3      56885/tcp   mountd
143/tcp  open  imap     Dovecot imapd (Ubuntu)
|_ssl-date: TLS randomness does not represent time
|_imap-capabilities: ENABLE OK Pre-login post-login have listed IMAP4rev1 LOGINDISABLEDA0001 capabilities LITERAL+ more LOGIN-REFERRALS STARTTLS IDLE ID SASL-IR
| ssl-cert: Subject: commonNService Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 24.63 secondsame=enigma
| Subject Alternative Name: DNS:enigma
| Not valid before: 2026-02-18T20:33:33
|_Not valid after:  2036-02-16T20:33:33
993/tcp  open  ssl/imap Dovecot imapd (Ubuntu)
| ssl-cert: Subject: commonName=enigma
| Subject Alternative Name: DNS:enigma
| Not valid before: 2026-02-18T20:33:33
|_Not valid after:  2036-02-16T20:33:33
|_imap-capabilities: ENABLE Pre-login OK have listed IMAP4rev1 post-login capabilities LITERAL+ more SASL-IR LOGIN-REFERRALS IDLE ID AUTH=PLAINA0001
|_ssl-date: TLS randomness does not represent time
995/tcp  open  ssl/pop3 Dovecot pop3d
| ssl-cert: Subject: commonName=enigma
| Subject Alternative Name: DNS:enigma
| Not valid before: 2026-02-18T20:33:33
|_Not valid after:  2036-02-16T20:33:33
|_ssl-date: TLS randomness does not represent time
|_pop3-capabilities: TOP SASL(PLAIN) AUTH-RESP-CODE PIPELINING RESP-CODES UIDL CAPA USER
2049/tcp open  nfs      3-4 (RPC #100003)
```

# NFS Enumeration
## Show shares

```js
    ~/Téléchargements/CHall ❯ showmount -e 10.129.25.69                                               5s   00:06:53
Export list for 10.129.25.69:
/srv/nfs/onboarding *
```

## Connect to shares
![](/assets/IMG-20260628001942160.png)

## Info Find

![](/assets/IMG-20260628002034331.png)

```js
Employee: Kevin Mitchell
Department: Operations
Date: 2024-03-01
Url: http://mail001.enigma.htb
Username: kevin
Password: Enigma2024!
```

# IMAP Enumeration

![](/assets/IMG-20260628003020765.png)

```js

    ~/Téléchargements/CHall ❯ openssl s_client -connect 10.129.25.69:993 -crlf -quiet 

* 1 FETCH (BODY[] {1473}
Return-Path: <sarah@enigma.htb>
X-Original-To: kevin@localhost
Delivered-To: kevin@localhost
Received: from enigma (localhost [127.0.0.1])
	by enigma (Postfix) with ESMTP id 673F7211B9
	for <kevin@localhost>; Wed, 18 Feb 2026 21:29:13 +0000 (UTC)
Date: Wed, 18 Feb 2026 21:29:13 +0000
To: kevin@localhost
From: sarah@enigma.htb
Subject: Welcome to Enigma Corp, Kevin!
Message-Id: <20260218212913.010896@enigma>
X-Mailer: swaks v20240103.0 jetmore.org/john/code/swaks/

Hi Kevin,

Welcome to the team! We're thrilled to have you on board at Enigma Corp.

A little about us — Enigma Corp is a mid-sized technology and operations firm specializing in infrastructure management and enterprise solutions. We've been growing rapidly over the past few years and we're excited to have fresh talent joining us.

I'm Sarah from the Accounts department. I'll be your point of contact for any finance-related queries during your onboarding period.

We're still finalizing a few of your onboarding details — your system access, equipment setup, and department introductions are all being arranged by the IT team. You should be receiving your access credentials shortly via the company shared drive.

In the meantime, don't hesitate to reach out if you have any questions. We want to make sure your first few days are as smooth as possible.

Looking forward to working with you!

Best regards,
Sarah
Accounts Department
Enigma Corp
sarah@enigma.htb
```
## Finding

```js
sarah@enigma.htb
```

# POP3 Enumeration

![](/assets/IMG-20260628005327999.png)

## Finding

```js
OK Dovecot (Ubuntu) ready.
USER kevin
+OK
PASS Enigma2024!
+OK Logged in.
LIST
+OK 1 messages:
1 1473
.
STAT
+OK 1 1473
RETR 1
+OK 1473 octets
Return-Path: <sarah@enigma.htb>
X-Original-To: kevin@localhost
Delivered-To: kevin@localhost
Received: from enigma (localhost [127.0.0.1])
	by enigma (Postfix) with ESMTP id 673F7211B9
	for <kevin@localhost>; Wed, 18 Feb 2026 21:29:13 +0000 (UTC)
Date: Wed, 18 Feb 2026 21:29:13 +0000
To: kevin@localhost
From: sarah@enigma.htb
Subject: Welcome to Enigma Corp, Kevin!
Message-Id: <20260218212913.010896@enigma>
X-Mailer: swaks v20240103.0 jetmore.org/john/code/swaks/

Hi Kevin,

Welcome to the team! We're thrilled to have you on board at Enigma Corp.

A little about us — Enigma Corp is a mid-sized technology and operations firm specializing in infrastructure management and enterprise solutions. We've been growing rapidly over the past few years and we're excited to have fresh talent joining us.

I'm Sarah from the Accounts department. I'll be your point of contact for any finance-related queries during your onboarding period.

We're still finalizing a few of your onboarding details — your system access, equipment setup, and department introductions are all being arranged by the IT team. You should be receiving your access credentials shortly via the company shared drive.

In the meantime, don't hesitate to reach out if you have any questions. We want to make sure your first few days are as smooth as possible.

Looking forward to working with you!

Best regards,
Sarah
Accounts Department
Enigma Corp
sarah@enigma.htb
```
# Web Enumeration

![](/assets/IMG-20260628003953720.png)


## Directory Fuzzing

![](/assets/IMG-20260628004518255.png)

## Sub-Domains Fuzzing

![](/assets/IMG-20260628004440808.png)

```js
http://mail001.enigma.htb
```

![](/assets/IMG-20260628010853283.png)

### Use Kevin Creds To connect

![](/assets/IMG-20260628011030745.png)


### Now use kevin password to connect to sarah account

![](/assets/IMG-20260705150954069.png)


![](/assets/IMG-20260705151048689.png)

![](/assets/IMG-20260705151128982.png)

#### Find

```js
http://support_001.enigma.htb/
```

```js
Username: admin  
Password: Ne3s4rtars78s
```

#### Connection au site avec les creds trouver dans le mail

![](/assets/IMG-20260705152616836.png)

## OpenSTAManager version 2.9.8 vulnerable au [CVE-2025-69212]

Le CVE-2025-69212 est une faille de sécurité critique de type injection de commandes système (OS Command Injection) découverte dans OpenSTAManager, un logiciel open-source de gestion d'interventions techniques et de facturation.

Avec un score de gravité CVSS de 8,8, cette vulnérabilité permet à un attaquant connecté d'exécuter des commandes arbitraires sur le serveur.

## Résumé de la faille

- Logiciel concerné : OpenSTAManager
- Versions vulnérables : Version 2.9.8 et toutes les versions antérieures
- Type de faille : Injection de commandes OS (CWE-78)
- Impact : Exécution de code à distance (RCE) / Compromission totale du serveur

## Comment fonctionne l'attaque ?

La vulnérabilité se situe dans le module de décodage des fichiers signés P7M (XML signés).

1. Un attaquant authentifié téléverse un fichier ZIP sur le serveur.
2. Ce fichier ZIP contient un fichier `.p7m` dont le nom intègre des commandes malveillantes.
3. Lors du traitement ou du décodage du fichier par l'application, le système ne nettoie pas correctement ce nom de fichier.
4. Le serveur exécute alors les commandes cachées dans le nom du fichier avec les privilèges de l'application web.

# PoC
https://github.com/devcode-it/openstamanager/security/advisories/GHSA-25fp-8w8p-mx36

![](/assets/IMG-20260705162819945.png)

![](/assets/IMG-20260705162834461.png)


# Reverse Shell

![](/assets/IMG-20260705162944972.png)

## Find

![](/assets/IMG-20260705164327629.png)

## Mysql Creds

```
user : brollin
pass : Fri3nds@9099
```

### Haris creds hashed find

![](/assets/Pasted image 20260706193417.png)

```js
haris:$2y$10$WHf1T79sxjsZongUKT2jGeexTkvihBQyCZeoYXmObiNphrsZDr6eC
```

## Hash crack
![](/assets/Pasted image 20260706193657.png)

```js
bestfriends
```


# User Flag

![](/assets/Pasted image 20260706193831.png)

```js
bf51e57b117e02d2044ee30f74c021af
```

# Decouverte d'un proc qui tourne sur le port 1337

![](/assets/IMG-20260707110240000.png)


## Port Forwarding pour communiquer avec ce dernier sur ma machine hote

![](/assets/IMG-20260707110325683.png)



```js
    ~/Téléchargements/CHall ❯ ssh -i id_rsa -N \                              
  -L 1337:127.0.0.1:1337 \
  haris@10.129.48.127           
```

![](/assets/IMG-20260707110426915.png)


Le site tourne sur du [OliveTin 3000.10.0] vulnerable a la [CVE-2026-27626]

## Description de la CVE [CVE-2026-27626]

`La vérification de sécurité du mode « shell » d'OliveTin (checkShellArgumentSafety) bloque plusieurs types d'arguments dangereux, mais pas les mots de passe. Un utilisateur fournissant un argument de type « mot de passe » peut injecter des métacaractères shell permettant l'exécution de commandes arbitraires sur le système d'exploitation. Un second vecteur indépendant permet une exécution de code à distance (RCE) sans authentification via des valeurs JSON extraites de webhooks, lesquelles contournent totalement les contrôles de type avant d'être transmises à `sh -c`.`

## Finding

![](/assets/IMG-20260707112019567.png)

### Alice Creds

```js
alice:$argon2id$v=19$m=65536,t=4,p=2$puyxA0s555TSFx7hnFLCXA$PyhLGpZtvpMMvc2DgMWkM8OJMKO55euwV5gm//1iwx4
```

