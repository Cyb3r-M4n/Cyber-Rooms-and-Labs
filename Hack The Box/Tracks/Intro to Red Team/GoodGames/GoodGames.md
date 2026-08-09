
# Target : 10.129.63.171

# Enumeration des ports et services

```js
nmap -sV -sC 10.129.63.171
```

```js
Starting Nmap 7.99 ( https://nmap.org ) at 2026-08-05 16:53 +0000
Nmap scan report for 10.129.63.171
Host is up (0.29s latency).
Not shown: 999 closed tcp ports (reset)
PORT   STATE SERVICE VERSION
80/tcp open  http    Werkzeug httpd 2.0.2 (Python 3.9.2)
|_http-trane-info: Problem with XML parsing of /evox/about
|_http-title: GoodGames | Community and Store
|_http-server-header: Werkzeug/2.0.2 Python/3.9.2

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 522.99 seconds
```

## Enumeration du port 80 (http)

