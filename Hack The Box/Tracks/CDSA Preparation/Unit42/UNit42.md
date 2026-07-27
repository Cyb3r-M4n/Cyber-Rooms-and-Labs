- **Event ID 1**: Création/Exécution de processus. Inclut le chemin de processus, le chemin de processus parent et les arguments en ligne de commande.
- **Event ID 2**: Temps de création de fichier modifié. Inclut le fichier effectuant la modification, le fichier auquel la modification est effectuée, l'horodatage altéré et l'horodatage original.
- **Event ID 3**: Connexion réseau. Inclut le processus de connexion, adresse IP de destination et port.
- **Event ID 5** : Terminaison de processus. Inclut le nom du processus qui a été tué ou terminé lui-même.
- **Event ID 11**: Création du fichier. Inclut le processus de création du fichier, le fichier en cours de création et son chemin complet.
- **Event ID 22**: requête DNS. Inclut le processus d'interrogation du domaine, le nom de domaine cible et les adresses IP auxquelles ils se résolvent.

Dans ce Challenge j'ai recu un ficher `Microsoft-Windows-Sysmon-Operational.evtx` 

Pour analyser les logs de ce ficher j'ai besoin d'un outils `evtx_dump` 

# Installation
## EVTX Viewer

```js
https://omerbenamram.github.io/evtx/
```

# Nombre d'Event ID = 11

![](/assets/IMG-20260715101028289.png)

==**Nombre d'event ID 11 : 56**==

# Process malicieux ayant infecter le system de la victime (Event ID = 1)

Je vais trier les logs en fonction de l'ID, nous avons trouver le process malicieux et les informations le concernant

![](/assets/IMG-20260715101854356.png)

==**C:\Users\CyberJunkie\Downloads\Preventivo24.02.14.exe.exe**==

# Lecteur Cloud ayant ete utiliser pour distribuer le malware

J'ai trier les logs en fonction de l'ID 22 car ce dernier inclut tout ce qui est DNS et resolution de nom de domaine et surement pour un Cloud qui est distant il doit forcement etre resolue avant d'avoir un communication avec le reseau interne

![](/assets/IMG-20260715225126420.png)

==**dropbox**==

# Evasion de privilege avec `Time Stomping` : Trouver la nouvelle Date

Avec l'Event ID 2 j'ai pu filtrer les logs car cet ID permet de voir les information detailler sur les fichers modifier

![](/assets/IMG-20260715225841254.png)

==**2024-01-14 08:10:06**==

# Chemin complet des nouvelles ficher deposer sur le system

Filtrage avec l'Event ID : 11 qui lui prend en charge tout les process de creation de ficher

![](/assets/IMG-20260715230250219.png)

==**C:\Users\CyberJunkie\AppData\Roaming\Photo and Fax Vn\Photo and vn 1.1.2\install\F97891C\WindowsVolume\Games\once.cmd**==

# Nom de domaine auquel le ficher malveillant a tente d'atteindre

Filtrage avec l'Event ID : 22

![](/assets/IMG-20260715230625951.png)

==**www.example.com**==

# Adresse IP auquel le processus malveillant a tenter de tendre la main

Ici en filtrant l'Event ID : 3 qui lui autre prend en charge tout les connexion reseau, Nous avons pu trouver l'adresse IP auquel le processus malveillant a tenter de faire appel

![](/assets/IMG-20260715231159376.png)

==**93.184.216.34**==

# Temps de terminaison du processus Malveillant

Avec L'Event ID 5 qui prend en charge tout terminaison de processus j'ai pu trouver le temps a laquel le processus Malveillant se terminait

![](/assets/IMG-20260715231508120.png)

==**2024-02-14 03:41:58**==


![](/assets/IMG-20260715231623864.png)

