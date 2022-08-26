---
title: Introduction à l'administration Linux
parent: Linux
grand_parent: Labs
---

# Introduction à l'administration Linux
{: .no_toc }

> Hello everybody out there using minix -
> 
> I'm doing a (free) operating system (just a hobby, won't be big and
> professional like gnu) for 386(486) AT clones. This has been brewing
> since april, and is starting to get ready. I'd like any feedback on
> things people like/dislike in minix, as my OS resembles it somewhat
> (same physical layout of the file-system (due to practical reasons)
> among other things).
> 
> I've currently ported bash(1.08) and gcc(1.40), and things seem to work.
> This implies that I'll get something practical within a few months, and
> I'd like to know what features most people would want. Any suggestions
> are welcome, but I won't promise I'll implement them :-)
> 
> Linus

1. TOC
{:toc}

## Objectifs

Ce cours est l'occasion de vous initier au fonctionnement d'un système GNU/Linux et à son administration.

À l'issue du mini-projet, vous serez capable d'installer et configurer un serveur Linux. Vous aurez connaissance des tâches de base qui incombent aux administrateurs système, et pourrez en automatiser une partie : vous connaîtrez le langage du shell Bash et sa mise en œuvre dans un script exécutable.

## Prérequis

Aucun, ou presque ! Quelques ressources pourront vous aider au cours du projet :

* La documentation en français pour [un serveur sous Ubuntu](https://doc.ubuntu-fr.org/serveur). Certaines informations peuvent être un peu datées, mais elle a le mérite de couvrir un large éventail de sujets ;
* Le [Ubuntu Server Guide](https://ubuntu.com/server/docs), en anglais, est écrit par Canonical, la société éditrice d'Ubuntu. N'hésitez pas à vous y référer, elle est à jour et très complète ;
* Le livre de Vincent Lozano, [*Tout ce que vous avez toujours voulu savoir Unix sans jamais oser le demander*](http://lozzone.free.fr/unix/guide-unix.pdf), est un manuel pour débutants très complet.

## Évaluation

Vous restituerez ce mini-projet en produisant une archive contenant tous les fichiers que vous jugerez utile de fournir, ainsi qu'un compte-rendu comportant vos réponses aux questions qui seront posées tout au long du sujet, et toute remarque ou commentaire que vous souhaiteriez ajouter.

🔎 Les paragraphes précédés de ce symbole vous invitent à faire des recherches rapides pour compléter votre réponse.

## TD0 : le shell Bash

### Objectifs

Ces exercices ont pour objet de vous familiariser avec l'usage du shell. La ligne de commande a de nombreux avantages : uniformité des commandes, flexibilité, répétabilité, accès à distance et automatisation... Mais tout a un prix ! En contrepartie, il faut apprendre et mémoriser les commandes essentielles. Seule la pratique vous permettra d'être efficace face à un shell.

### Déroulé

Si vous n'avez pas de shell Bash à disposition, vous pouvez utiliser un shell en ligne, comme proposé par [replit](https://replit.com/languages/bash) ou [OnlineGDB](https://www.onlinegdb.com/online_bash_shell). Attention, votre session sera **temporaire** et vous ne retrouverez pas votre travail à la prochaine connexion.

Sur votre machine, si vous utilisez Windows, vous pouvez également activer [WSL2](https://docs.microsoft.com/fr-fr/windows/wsl/install) ou installer [Git Bash](https://git-scm.com/downloads).

Reportez vos réponses au fur et à mesure dans votre compte-rendu, et n'oubliez pas de sauvegarder votre travail !

🔎 Prévoyez dans le compte-rendu une section "mémento" dans laquelle vous listerez toutes les commandes que vous utiliserez, avec une courte phrase explicative pour chacune d'entre elles. Pour obtenir des informations sur une commande, votre réflexe doit être `man`. Par exemple, pour afficher le manuel de la commande `ls`, on tape :

```bash
man ls
```

Et on obtient :

![](./images/man-ls.png)

Parfois, ces pages de manuel ne fournissent pas d'exemple d'utilisation d'une commande. Il existe une base de données communautaire pour cela, [tldr.sh](https://tldr.sh/).

Pour vous aider à démarrer, voici une liste des commandes que vous allez devoir utiliser : `cat`, `cd`, `echo`, `grep`, `ls`, `mkdir`, `pwd`, `touch`, `wc`. 

1. Quel est votre nom d'utilisateur ? Affichez la valeur de la variable `$USER`.
2. Identifiez le répertoire dans lequel vous vous situez au démarrage de votre shell.
3. Créez un répertoire `exercices` dans votre répertoire utilisateur (*home*, en anglais). Pour cela, utilisez la variable `$HOME`.
4. Déplacez-vous dans ce répertoire.
5. Créez un fichier `exercices.txt`.
6. Dans ce fichier, sans utiliser d'éditeur de texte ([indice](https://en.wikipedia.org/wiki/Here_document) : vous allez utiliser une redirection), écrivez les [pangrammes](https://fr.wikipedia.org/wiki/Pangramme) suivant :

    > The quick brown fox jumps over the lazy dog.  
    > Waltz, bad nymph, for quick jigs vex.  
    > Glib jocks quiz nymph to vex dwarf.  
    > Sphinx of black quartz, judge my vow.  
    > Sphinx of black quartz, judge my vow.  
    > How vexingly quick daft zebras jump!  
    > The five boxing wizards jump quickly.  
    > Jackdaws love my big sphinx of quartz.  
    > Pack my box with five dozen liquor jugs.

7. Ajoutez la ligne suivante au fichier :

    > Pack my box with five dozen liquor jugs.

8.  Affichez le contenu du fichier.
9.  Comptez le nombre de pangrammes que contient le fichier.
10. Comptez le nombre d'occurrences du mot `quick` ([indice](https://en.wikipedia.org/wiki/Pipeline_(Unix)) : vous allez chaîner deux commandes).
11. Un pangramme apparaît en double dans le fichier. Dans une même commande, triez les pangrammes par ordre alphabétique (sur leur première lettre), débarrassez-vous du doublon, et écrivez le résultat dans un nouveau fichier `pangrammes.txt`.

## TD1 : installation du système

### Objectifs

Ce premier TD ne concerne pas l'installation d'une distribution Linux "de bureau" que vous utiliseriez au quotidien sur votre machine. Notre cours adresse la question de l'*administration* d'un système Linux : nous allons mettre en place une machine virtuelle (VM, pour *Virtual Machine*) Linux qui fera office de *serveur*.

![Half-filled server rack](./images/wip-server-racks.jpg "Half-filled server rack")

[Alexis Lê-Quôc](https://commons.wikimedia.org/wiki/File:Half_filled_server_racks.jpg)

Sur la photo ci-dessus, on voit une baie de serveurs en cours de montage. Les machines sont disposées ainsi dans un souci de minimiser leur encombrement et de faciliter leur refroidissement. On s'imagine mal devoir brancher claviers et écrans en cas d'intervention ! Pour cela, on accède au système *à distance*, grâce à un protocole célèbre : SSH (pour *Secure Shell*).

Vous accéderez donc toujours via SSH à la machine virtuelle que vous allez déployer.

### Déroulé

#### Installation de VirtualBox

Créer des machines virtuelles, c'est virtualiser les ressources physiques du système hôte, pour les partager entre des systèmes invités. Ce type de virtualisation est assisté par le matériel, qui fournit les fonctionnalités d'isolation requises pour assurer l'étanchéité entre les VM.

Cela permet de faire fonctionner, sur une même machine (l'hôte), de nombreux systèmes d'exploitation (invités) complets et hétérogènes, de manière indépendante, sur des ressources matérielles partagées.

Du point de vue d'une machine virtuelle, son environnement d'exécution est perçu comme une plateforme à part entière -- alors qu'il est en réalité un sous-ensemble des ressources matérielles de la plateforme hôte. Ce sous-ensemble est créé et géré par un *hyperviseur* (ou *VMM*, pour *Virtual Machine Manager*), un logiciel de bas niveau qui peut être exécuté en tant que système d'exploitation, ou comme un processus géré par le système d'exploitation hôte.

L'hyperviseur a pour responsabilité la gestion du cycle de vie des machines virtuelles : création, exécution, destruction et parfois migration des VM sont assurées par l'hyperviseur.

Il existe deux abstractions pour un hyperviseur :

* Type-1 (*bare-metal hypervisors*) : ces hyperviseurs fonctionnent à même le matériel de la machine hôte, sans l'intervention d'un système d'exploitation -- on peut considérer qu'ils sont eux-mêmes une forme de système d'exploitation. L'absence d'OS hôte entre le matériel et l'hyperviseur garantit une sécurité supérieure (la surface d'attaque est réduite) et de meilleures performances (moins d'indirection). Parmi les hyperviseurs type-1 de référence, on trouve VMware ESXi, KVM, Xen ou Hyper-V ;
* Type-2 (*hosted hypervisors*) : ces hyperviseurs s'exécutent en tant que processus d'un système d'exploitation hôte tel que Linux ou Windows. Ce sont des produits dédiés aux consommateurs finaux (nous !), qui leur permettent de manipuler des systèmes d'exploitation hétérogènes sur une même machine hôte. Les plus célèbres sont QEMU et VirtualBox.

![](./images/hypervisors.png)

1. Installez [VirtualBox](https://www.virtualbox.org/wiki/Downloads) : choisissez le *Platform package* adapté à votre système hôte.

#### Création de la VM

Deux notions sont importantes pour cette étape :

* Image disque : un fichier, souvent d'extension `.iso` ou `.img`, qui représente un média amorçable (*bootable*) que l'on pourrait copier sur un disque flash par exemple. Il contient un chargeur d'amorçage et un système d'exploitation. Ces images disques sont utilisées pour installer un nouvel OS sur une machine, physique ou virtuelle ;
* Disque virtuel : un fichier, souvent d'extension `.vdi`, qui représente le disque d'amorçage d'un système d'exploitation.

1. Téléchargez une image disque de [Ubuntu Server](https://ubuntu.com/download/server).

2. Dans la fenêtre principale de VirtualBox, cliquez sur le bouton "Nouvelle" et suivez le guide :
    * 2048 Mo de mémoire vive devraient suffire ;
    * Choisissez de créer un *disque dur virtuel*, de type **VDI**, dynamiquement alloué avec une taille de départ de 10 Go.

3. Démarrez votre VM fraîchement créée. VirtualBox va vous demander de choisir un *disque de démarrage*. Ajoutez l'image disque que vous avez téléchargée, `ubuntu-22.04.1-live-server-amd64.iso`.

4. Si tout s'est bien passé, voici l'écran que vous devriez voir s'afficher :

    ![](./images/virtualbox/virtualbox-grub.png)

C'est le chargeur d'armoçage, *GRUB*. Vous pouvez valider le choix *Try or Install Ubuntu Server* et poursuivre le démarrage de l'OS.

#### Installation d'Ubuntu Server

Vous allez pouvoir vous lancer dans l'installation du système à proprement parler. Un assistant va vous guider tout au long de la procédure : vous pouvez utiliser les flèches du clavier et la touche de tabulation <kbd>↹</kbd> pour naviguer entre les boutons et les écrans.

1. Choisissez la langue et la disposition du clavier de votre choix. Si vous utilisez un clavier Azerty, la disposition à choisir est "French".

2. Le type d'installation à sélectionner est *Ubuntu Server (**minimized**)* :

    ![](./images/virtualbox/virtualbox-server-minimized.png)

3. La connexion au réseau devrait s'effectuer d'elle-même. Vous n'avez pas besoin de préciser d'adresse de proxy. L'adresse du miroir d'archive Ubuntu est correcte par défaut.

4. Vous arrivez à l'étape de configuration du stockage. Sélectionnez "Custom storage layout" :

    ![](./images/virtualbox/virtualbox-server-storage.png)

##### Partitionnement

1. Créez deux partitions : une pour la racine du système de fichiers, et une pour les répertoires utilisateur. Chacune prendra la moitié de l'espace disque total. Formatez-les avec le système de fichiers `ext4`.

    ![](./images/virtualbox/virtualbox-server-partitions-1.png)

2. Faîtes une capture d'écran du schéma de partitionnement final et ajoutez-la à votre compte-rendu.

🔎 À votre avis, à quoi sert de partitionner le disque sur lequel on installe un système ? En un court paragraphe, proposez une réponse dans votre compte-rendu.

##### Serveur SSH

L'assistant d'installation vous demandera ensuite des informations sur votre profil et le nom de la machine.

À l'étape suivante, on vous propose d'installer le serveur OpenSSH. C'est ce service qui vous permettra d'accéder à distance à votre machine.

![](./images/virtualbox/virtualbox-server-ssh.png)

Si vous avez déjà un jeu de clefs SSH, vous pouvez les importer. Sinon, vous vous connecterez avec votre identifiant et votre mot de passe.

🔎 Qu'est-ce que sont ces clefs ? À quoi servent-elles ? En un court paragraphe, proposez une réponse dans votre compte-rendu.

##### Finalisation

La dernière étape vous propose une liste de paquets suggérés : n'en sélectionnez aucun et poursuivez jusqu'à la fin de l'installation d'Ubuntu.

![](./images/virtualbox/virtualbox-server-finished.png)

Lorsque c'est fini, vous pouvez choisir de "Redémarrer maintenant".

## TD2 : configuration d'un serveur Linux

### Objectifs

Cette seconde partie va nous permettre d'aborder les questions de réseau et de services.

TODO: Service de base : serveur web

TODO: NAT pour les ports avec VirtualBox

### Déroulé

* architecture client/serveur
* serveur écoute sur un port, en attente de connexion de la part d'un client

* ouverture de port pour SSH

![](images/virtualbox/virtualbox-ssh-nat.png)

Pour accéder à votre machine virtuelle *via* son serveur SSH, il vous faut un... client SSH. Puisque les étapes suivantes du projet consistent à développer des scripts Bash, nous allons utiliser un IDE (*Integrated Development Environment*) livré avec un terminal et un client SSH.

1. Si vous ne l'avez pas déjà installé, [Visual Studio Code](https://code.visualstudio.com/) est un excellent IDE, développé par Microsoft. Récupérez VSCode et exécutez-le sur votre machine.

2. VSCode est un IDE *modulaire* : cela signifie que de nombreuses fonctionnalités sont accessibles via l'installation d'*extensions*. Microsoft propose une extension *Remote - SSH* qui permet de se connecter à une machine *via* SSH pour y travailler à distance. Installez l'extension :

    ![](./images/vscode/vscode-remote-extension.png)

3. Connectez-vous à votre machine virtuelle :

    ![](./images/vscode/vscode-remote-host.png)

4. Rentrez le mot de passe de votre utilisateur :

    ![](./images/vscode/vscode-remote-password.png)

5. Ouvrez un répertoire pour commencer à travailler :

    ![](./images/vscode/vscode-remote-folder.png)

* serveur web
  * configuration nginx
  * ouverture de port

* logwatch
  * configuration pour nginx

#### Installation d'un paquet

`logwatch`

```
sudo apt update
sudo apt dist-upgrade
sudo apt install logwatch
```

logwatch + nginx

## TD3 : introduction à l'automatisation

### Objectifs

TODO: Script shell...

TODO: Création de backups...

TODO: Extraction de backups...

### Déroulé

1. TODO: VSCode remote + shellcheck

## TD4 : développement d'un script d'administration

### Objectifs

TODO: Fonctionnalités attendues...

TODO: Idempotence...

* https://unix.stackexchange.com/questions/4899/var-vs-var-and-to-quote-or-not-to-quote

* Utiliser un template pour un [script Bash sans danger](https://gist.github.com/m-radzikowski/53e0b39e9a59a1518990e76c2bff8038)
* Lire l'article du créateur du script https://betterdev.blog/minimal-safe-bash-script-template/
