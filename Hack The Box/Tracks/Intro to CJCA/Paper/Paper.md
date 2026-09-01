# Target : 10.129.136.31

# Enumeration des ports et services

```js
nmap -sV -sC -Pn 10.129.136.31 -A -O
```

```js
Starting Nmap 7.99 ( https://nmap.org ) at 2026-07-20 21:53 +0000
Nmap scan report for 10.129.136.31
Host is up (0.15s latency).
Not shown: 997 closed tcp ports (reset)
PORT    STATE SERVICE  VERSION
22/tcp  open  ssh      OpenSSH 8.0 (protocol 2.0)
| ssh-hostkey: 
|   2048 10:05:ea:50:56:a6:00:cb:1c:9c:93:df:5f:83:e0:64 (RSA)
|   256 58:8c:82:1c:c6:63:2a:83:87:5c:2f:2b:4f:4d:c3:79 (ECDSA)
|_  256 31:78:af:d1:3b:c4:2e:9d:60:4e:eb:5d:03:ec:a0:22 (ED25519)
80/tcp  open  http     Apache httpd 2.4.37 ((centos) OpenSSL/1.1.1k mod_fcgid/2.3.9)
|_http-generator: HTML Tidy for HTML5 for Linux version 5.7.28
| http-methods: 
|_  Potentially risky methods: TRACE
|_http-server-header: Apache/2.4.37 (centos) OpenSSL/1.1.1k mod_fcgid/2.3.9
|_http-title: HTTP Server Test Page powered by CentOS
443/tcp open  ssl/http Apache httpd 2.4.37 ((centos) OpenSSL/1.1.1k mod_fcgid/2.3.9)
|_http-title: HTTP Server Test Page powered by CentOS
|_http-generator: HTML Tidy for HTML5 for Linux version 5.7.28
| http-methods: 
|_  Potentially risky methods: TRACE
| ssl-cert: Subject: commonName=localhost.localdomain/organizationName=Unspecified/countryName=US
| Subject Alternative Name: DNS:localhost.localdomain
| Not valid before: 2021-07-03T08:52:34
|_Not valid after:  2022-07-08T10:32:34
|_http-server-header: Apache/2.4.37 (centos) OpenSSL/1.1.1k mod_fcgid/2.3.9
| tls-alpn: 
|_  http/1.1
|_ssl-date: TLS randomness does not represent time
No exact OS matches for host (If you know what OS is running on it, see https://nmap.org/submit/ ).
TCP/IP fingerprint:
OS:SCAN(V=7.99%E=4%D=7/20%OT=22%CT=1%CU=42763%PV=Y%DS=2%DC=T%G=Y%TM=6A5E990
OS:4%P=x86_64-pc-linux-gnu)SEQ(SP=103%GCD=1%ISR=108%TI=Z%CI=Z%II=I%TS=A)SEQ
OS:(SP=105%GCD=1%ISR=10E%TI=Z%CI=Z%II=I%TS=A)SEQ(SP=106%GCD=1%ISR=105%TI=Z%
OS:CI=Z%II=I%TS=A)SEQ(SP=106%GCD=1%ISR=10B%TI=Z%CI=Z%TS=A)SEQ(SP=FF%GCD=1%I
OS:SR=105%TI=Z%CI=Z%II=I%TS=A)OPS(O1=M552ST11NW7%O2=M552ST11NW7%O3=M552NNT1
OS:1NW7%O4=M552ST11NW7%O5=M552ST11NW7%O6=M552ST11)WIN(W1=7120%W2=7120%W3=71
OS:20%W4=7120%W5=7120%W6=7120)ECN(R=Y%DF=Y%T=40%W=7210%O=M552NNSNW7%CC=Y%Q=
OS:)T1(R=Y%DF=Y%T=40%S=O%A=S+%F=AS%RD=0%Q=)T2(R=N)T3(R=N)T4(R=Y%DF=Y%T=40%W
OS:=0%S=A%A=Z%F=R%O=%RD=0%Q=)T5(R=Y%DF=Y%T=40%W=0%S=Z%A=S+%F=AR%O=%RD=0%Q=)
OS:T6(R=Y%DF=Y%T=40%W=0%S=A%A=Z%F=R%O=%RD=0%Q=)T7(R=N)U1(R=Y%DF=N%T=40%IPL=
OS:164%UN=0%RIPL=G%RID=G%RIPCK=G%RUCK=G%RUD=G)IE(R=Y%DFI=N%T=40%CD=S)

Network Distance: 2 hops

TRACEROUTE (using port 111/tcp)
HOP RTT       ADDRESS
1   171.77 ms 10.10.14.1
2   171.89 ms 10.129.136.31

OS and Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 43.88 seconds
```

Backend server found : `office.paper`

![](/assets/IMG-20260720224757850.png)

Decouverte d'un site qui tourne sur du `wordpress`

## Enumeration des Users

```js
wpscan --url http://office.paper/ --api-token CWDkfvUj0UACC5L8jqPnOYrJMApXaa6Vl6sCMFHQAtA -e u
```

```js
prisonmike
nick
creedthoughts
```

## Password attack

`No valid password found`

Apres quelque recherche, j'ai trouver que ce dernier est vul au `CVE-2019-17671`

`Le **CVE-2019-17671** est une faille de sécurité critique affectant **WordPress (versions antérieures à 5.2.4)**. Elle permettait à n'importe quel utilisateur non authentifié de consulter des contenus normalement privés, protégés par mot de passe ou encore à l'état de brouillon`

## PoC

https://www.exploit-db.com/exploits/47690

![](/assets/IMG-20260720230643639.png)

## Contenu Prive

```js
test

Micheal please remove the secret from drafts for gods sake!

Hello employees of Blunder Tiffin,

Due to the orders from higher officials, every employee who were added to this blog is removed and they are migrated to our new chat system.

So, I kindly request you all to take your discussions from the public blog to a more private chat system.

-Nick

# Warning for Michael

Michael, you have to stop putting secrets in the drafts. It is a huge security issue and you have to stop doing it. -Nick

Threat Level Midnight

A MOTION PICTURE SCREENPLAY,  
WRITTEN AND DIRECTED BY  
MICHAEL SCOTT

[INT:DAY]

Inside the FBI, Agent Michael Scarn sits with his feet up on his desk. His robotic butler Dwigt….

# Secret Registration URL of new Employee chat system

http://chat.office.paper/register/8qozr226AhkCHZdyY

# I am keeping this draft unpublished, as unpublished drafts cannot be accessed by outsiders. I am not that ignorant, Nick.

# Also, stop looking at my drafts. Jeez!
```

```js
prisonmike
nick
creedthoughts
Michael
jeez
```
## Decouverte d'un sous domaine

```js
chat.office.paper
```
 *URL : http://chat.office.paper/register/8qozr226AhkCHZdyY*

## Creation de compte et trouvaille de lfi

![](/assets/IMG-20260722122705650.png)
## Creds found 
```js
user : recyclops | pass : Queenofblad3s!23
```

## Connection SSH au serveur avec l'user dwight et le cred trouver

![](/assets/IMG-20260722122642318.png)
## User flag : dc238ec1a672de4e1d79626603e6bec4


## Privilege escalation

### Found

```js
+export ROCKETCHAT_URL=myserver.com
+export ROCKETCHAT_USER=mybotuser
+export ROCKETCHAT_PASSWORD=mypassword
+export ROCKETCHAT_ROOM=general
+export ROCKETCHAT_USESSL=true
```

Apres une enorme heure d'enumeration difficile et c'est linpeas qui nous a sauve de la noyade
la machine est vuln a `CVE-2026-43284`

`CVE-2026-43284, also known as "Dirty Frag," is a critical Linux kernel privilege escalation vulnerability. It allows unprivileged local users to write to the page cache and overwrite read-only files. This flaw is widely documented on GitHub, with publicly available exploit code used for reproduction and security testing`

## PoC

https://github.com/V4bel/dirtyfrag

```js
gcc -O0 -Wall -o exp exp.c -lutil && ./exp
```

![](/assets/IMG-20260722122608254.png)

# Root Flag : b1fa76ce204262582845c953d882dd11

