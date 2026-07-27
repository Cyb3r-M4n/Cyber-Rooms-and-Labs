
# Target : 10.130.135.246

# Enumeration nmap 

```js
nmap -sV -sC -Pn 10.130.135.246 -A -O
```

```js
Starting Nmap 7.99 ( https://nmap.org ) at 2026-07-26 12:14 +0000
Nmap scan report for 10.130.135.246
Host is up (0.17s latency).
Not shown: 996 closed tcp ports (reset)
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 8.9p1 Ubuntu 3ubuntu0.13 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   256 13:3a:c1:0c:bc:e3:c0:e2:5a:e0:8c:a0:42:fd:1f:e9 (ECDSA)
|_  256 53:94:43:c6:65:f1:c2:dc:e1:02:3e:b5:3f:9b:41:e4 (ED25519)
25/tcp open  smtp
| fingerprint-strings: 
|   GenericLines: 
|     220 hopaitech.thm ESMTP HopAI Mail Server Ready
|     Error: bad syntax
|     Error: bad syntax
|   GetRequest: 
|     220 hopaitech.thm ESMTP HopAI Mail Server Ready
|     Error: command "GET" not recognized
|     Error: bad syntax
|   Hello: 
|     220 hopaitech.thm ESMTP HopAI Mail Server Ready
|     Syntax: EHLO hostname
|   Help: 
|     220 hopaitech.thm ESMTP HopAI Mail Server Ready
|     Supported commands: AUTH HELP NOOP QUIT RSET VRFY
|   NULL: 
|_    220 hopaitech.thm ESMTP HopAI Mail Server Ready
|_smtp-commands: hopaitech.thm
53/tcp open  domain  (generic dns response: NXDOMAIN)
| fingerprint-strings: 
|   DNSVersionBindReqTCP: 
|     version
|_    bind
80/tcp open  http    Werkzeug httpd 3.1.4 (Python 3.11.14)
|_http-server-header: Werkzeug/3.1.4 Python/3.11.14
|_http-title: HopAI Technologies - Home
2 services unrecognized despite returning data. If you know the service/version, please submit the following fingerprints at https://nmap.org/cgi-bin/submit.cgi?new-service :
==============NEXT SERVICE FINGERPRINT (SUBMIT INDIVIDUALLY)==============
SF-Port25-TCP:V=7.99%I=7%D=7/26%Time=6A65FA1C%P=x86_64-pc-linux-gnu%r(NULL
SF:,31,"220\x20hopaitech\.thm\x20ESMTP\x20HopAI\x20Mail\x20Server\x20Ready
SF:\r\n")%r(Hello,4C,"220\x20hopaitech\.thm\x20ESMTP\x20HopAI\x20Mail\x20S
SF:erver\x20Ready\r\n501\x20Syntax:\x20EHLO\x20hostname\r\n")%r(Help,68,"2
SF:20\x20hopaitech\.thm\x20ESMTP\x20HopAI\x20Mail\x20Server\x20Ready\r\n25
SF:0\x20Supported\x20commands:\x20AUTH\x20HELP\x20NOOP\x20QUIT\x20RSET\x20
SF:VRFY\r\n")%r(GenericLines,5F,"220\x20hopaitech\.thm\x20ESMTP\x20HopAI\x
SF:20Mail\x20Server\x20Ready\r\n500\x20Error:\x20bad\x20syntax\r\n500\x20E
SF:rror:\x20bad\x20syntax\r\n")%r(GetRequest,71,"220\x20hopaitech\.thm\x20
SF:ESMTP\x20HopAI\x20Mail\x20Server\x20Ready\r\n500\x20Error:\x20command\x
SF:20\"GET\"\x20not\x20recognized\r\n500\x20Error:\x20bad\x20syntax\r\n");
==============NEXT SERVICE FINGERPRINT (SUBMIT INDIVIDUALLY)==============
SF-Port53-TCP:V=7.99%I=7%D=7/26%Time=6A65FA1C%P=x86_64-pc-linux-gnu%r(DNSV
SF:ersionBindReqTCP,20,"\0\x1e\0\x06\x81\x03\0\x01\0\0\0\0\0\0\x07version\
SF:x04bind\0\0\x10\0\x03");
No exact OS matches for host (If you know what OS is running on it, see https://nmap.org/submit/ ).
TCP/IP fingerprint:
OS:SCAN(V=7.99%E=4%D=7/26%OT=22%CT=1%CU=31505%PV=Y%DS=3%DC=T%G=Y%TM=6A65FA4
OS:F%P=x86_64-pc-linux-gnu)SEQ(SP=102%GCD=1%ISR=106%TI=Z%CI=Z%TS=A)SEQ(SP=1
OS:04%GCD=1%ISR=107%TI=Z%CI=Z%II=I%TS=A)SEQ(SP=104%GCD=1%ISR=10E%TI=Z%CI=Z%
OS:II=I%TS=A)SEQ(SP=105%GCD=1%ISR=109%TI=Z%CI=Z%II=I%TS=A)SEQ(SP=106%GCD=1%
OS:ISR=10C%TI=Z%CI=Z%II=I%TS=A)OPS(O1=M4E8ST11NW7%O2=M4E8ST11NW7%O3=M4E8NNT
OS:11NW7%O4=M4E8ST11NW7%O5=M4E8ST11NW7%O6=M4E8ST11)WIN(W1=F4B3%W2=F4B3%W3=F
OS:4B3%W4=F4B3%W5=F4B3%W6=F4B3)ECN(R=Y%DF=Y%T=40%W=F507%O=M4E8NNSNW7%CC=Y%Q
OS:=)T1(R=Y%DF=Y%T=40%S=O%A=S+%F=AS%RD=0%Q=)T2(R=N)T3(R=N)T4(R=Y%DF=Y%T=40%
OS:W=0%S=A%A=Z%F=R%O=%RD=0%Q=)T5(R=Y%DF=Y%T=40%W=0%S=Z%A=S+%F=AR%O=%RD=0%Q=
OS:)T6(R=Y%DF=Y%T=40%W=0%S=A%A=Z%F=R%O=%RD=0%Q=)T7(R=Y%DF=Y%T=40%W=0%S=Z%A=
OS:S+%F=AR%O=%RD=0%Q=)U1(R=Y%DF=N%T=40%IPL=164%UN=0%RIPL=G%RID=G%RIPCK=G%RU
OS:CK=G%RUD=G)IE(R=Y%DFI=N%T=40%CD=S)

Network Distance: 3 hops
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

TRACEROUTE (using port 143/tcp)
HOP RTT       ADDRESS
1   222.44 ms 192.168.128.1
2   ...
3   222.54 ms 10.130.135.246

OS and Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 60.68 seconds
```

## Enumeration http

![[IMG-20260726121707212.png]]


## User found 

```js
sir.carrotbane
shadow.whiskers
obsidian.fluff
nyx.nibbles
midnight.hop
crimson.ears
violet.thumper
grim.bounce
```

## DNS Recon 

```js
dig @10.130.135.246 hopaitech.thm AXFR
```

```js
; <<>> DiG 9.20.24-1+b1-Debian <<>> @10.130.135.246 hopaitech.thm AXFR
; (1 server found)
;; global options: +cmd
hopaitech.thm.		3600	IN	SOA	ns1.hopaitech.thm. admin.hopaitech.thm. 1 3600 1800 604800 86400
dns-manager.hopaitech.thm. 3600	IN	A	172.18.0.2
ns1.hopaitech.thm.	3600	IN	A	172.18.0.2
ticketing-system.hopaitech.thm.	3600 IN	A	172.18.0.3
url-analyzer.hopaitech.thm. 3600 IN	A	172.18.0.2
hopaitech.thm.		3600	IN	NS	ns1.hopaitech.thm.hopaitech.thm.
hopaitech.thm.		3600	IN	SOA	ns1.hopaitech.thm. admin.hopaitech.thm. 1 3600 1800 604800 86400
;; Query time: 147 msec
;; SERVER: 10.130.135.246#53(10.130.135.246) (TCP)
;; WHEN: Sun Jul 26 12:56:35 GMT 2026
;; XFR size: 7 records (messages 7, bytes 451)
```

### Domain found

```js
172.18.0.2 ns1.hopaitech.thm dns-manager.hopaitech.thm url-analyzer.hopaitech.thm
172.18.0.3 ticketing-system.hopaitech.thm
admin.hopaitech.thm
```

