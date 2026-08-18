
# Enumeration des ports

```js
nmap -sV -sC 10.129.52.26
```

```js
Starting Nmap 7.99 ( https://nmap.org ) at 2026-08-18 11:58 +0000
Nmap scan report for 10.129.52.26
Host is up (0.22s latency).
Not shown: 998 closed tcp ports (reset)
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 9.6p1 Ubuntu 3ubuntu13.5 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   256 31:83:eb:9f:15:f8:40:a5:04:9c:cb:3f:f6:ec:49:76 (ECDSA)
|_  256 6f:66:03:47:0e:8a:e0:03:97:67:5b:41:cf:e2:c7:c7 (ED25519)
80/tcp open  http    Apache httpd 2.4.58
|_http-title: Did not follow redirect to http://instant.htb/
|_http-server-header: Apache/2.4.58 (Ubuntu)
Service Info: Host: instant.htb; OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 143.60 seconds
```


# ENumeration du port 80

Sous domaine trouver apres avoir a lancer la commande `grep` sur l'application trouver

![](Pasted-image-20260818123031.png)

# Sous domaine trouver

```js
mywalletv1.instant.htb
```

