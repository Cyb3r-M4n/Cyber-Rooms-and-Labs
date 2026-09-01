# Target :

# Enumeration des ports et services

```js
nmap -sV -sC 10.129.52.108 -p- --min-rate=1000
```

```js
Starting Nmap 7.99 ( https://nmap.org ) at 2026-08-19 09:37 +0000
Nmap scan report for 10.129.52.108
Host is up (0.18s latency).
Not shown: 65532 closed tcp ports (reset)
PORT     STATE SERVICE VERSION
22/tcp   open  ssh     OpenSSH 8.4p1 Debian 5+deb11u1 (protocol 2.0)
| ssh-hostkey: 
|   3072 db:1d:5c:65:72:9b:c6:43:30:a5:2b:a0:f0:1a:d5:fc (RSA)
|   256 4f:79:56:c5:bf:20:f9:f1:4b:92:38:ed:ce:fa:ac:78 (ECDSA)
|_  256 df:47:55:4f:4a:d1:78:a8:9d:cd:f8:a0:2f:c0:fc:a9 (ED25519)
80/tcp   open  http    Apache httpd 2.4.54 ((Debian))
| http-cookie-flags: 
|   /: 
|     PHPSESSID: 
|_      httponly flag not set
|_http-title: Home
|_http-server-header: Apache/2.4.54 (Debian)
6379/tcp open  redis   Redis key-value store
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 86.51 seconds
```


# Enumeration du port 80 (http)

![[Pasted image 20260819093929.png]]


## Enumeration des sous domaines

```js
developers.collect.htb
forum.collect.htb
```


### Forum.collect.thb

FInding d'un ficher attachement  

```js
POST /set/role/admin HTTP/1.1
Host: collect.htb
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:104.0) Gecko/20100101 Firefox/104.0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8
Accept-Language: pt-BR,pt;q=0.8,en-US;q=0.5,en;q=0.3
Accept-Encoding: gzip, deflate
Connection: close
Cookie: PHPSESSID=r8qne20hig1k3li6prgk91t33j
Upgrade-Insecure-Requests: 1
Content-Type: application/x-www-form-urlencoded
Content-Length: 38

token=ddac62a28254561001277727cb397baf
```

