# Programmer le Cloud

1. TOC
{:toc}

## Prérequis

Pour mener à bien ce mini-projet, vous devrez vous appuyer sur les services gratuits de plusieurs fournisseurs. Ainsi, il vous faudra créer :

* un compte [GitHub](https://github.com/) pour héberger votre dépôt et réaliser l'intégration puis le déploiement continu ;
* un compte [Docker Hub](https://hub.docker.com/) pour publier l'image Docker de votre application ;
* un compte [Heroku](https://www.heroku.com/), enfin, qui vous servira à déployer l'application sur leur offre *Platform-as-a-Service*.

Pour développer localement, sur votre machine, il vous faudra installer :

* [Node.js](https://nodejs.org/en/) (version LTS, 16 actuellement) ;
* [Docker](https://docs.docker.com/get-docker/) ;
* [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli).

N'hésitez pas à travailler dans une machine virtuelle. Si vous utilisez Windows 10, le sous-système Linux pour Windows (*WSL*) est une bonne solution, en particulier car il fonctionne particulièrement bien avec l'IDE de Microsoft, Visual Studio Code :

* [Installer WSL 2 -- Microsoft Docs](https://docs.microsoft.com/fr-fr/windows/wsl/install)

Les instructions du TD seront données pour Ubuntu 20.04 (qui est notamment la distribution par défaut pour WSL2). **Vous êtes responsable de votre environnement de développement** : si vous n'êtes pas certain-e de le maîtriser, alignez-vous sur ce choix, qui vous permettra de gagner du temps sur les aspects opérationnels du projet.

## TD1 : une application Node.js

### Objectif

Dans ce premier TD, nous allons développer une micro-application pour **Node.js**. Elle sera écrite en **TypeScript**.

TypeScript est un sur-ensemble de JavaScript, développé par Microsoft et distribué sous licence Apache, qui permet le typage strict (pas de conversion implicite entre les types, pas de comportement inattendu des opérateurs) et statique (détection d'erreurs de programmation dès la compilation, pas d'état illégal durant l'exécution) des variables, l'utilisation de classes et d'interfaces ainsi que le découpage du code en modules, l'équivalent des espaces de noms en C++. Le code TypeScript est transpilé vers JavaScript avant son déploiement -- les sources sont vérifiées puis transformées en JavaScript par le compilateur : il ne s'agit pas d'une opération de compilation d'un code source vers du code machine, mais de source à source.

Node.js est un runtime pour JavaScript, c'est-à-dire une machine virtuelle qui fournit l'environnement d'exécution pour le langage. Node.js permet d'exécuter du code JavaScript côté serveur, et fournit dans sa bibliothèque standard un ensemble de primitives système. Node.js est livré avec `npm`, son gestionnaire de paquets, qui autorise l'installation et la gestion des dépendances d'une application.

La configuration d'un projet TypeScript demande un peu de travail préalable, c'est pourquoi vous partirez d'un projet dit *template* disponible sur GitHub. Vous créerez votre propre dépôt pour l'application à partir de ce template, via le bouton *"Use this template"* :

![Use this template](./images/github-template.png "GitHub template repository")

Votre application devra être capable de donner, à travers un accès par le web, des informations concernant le système sur lequel elle s'exécute : nombre de cœurs de processeur et charge actuelle, quantité de mémoire disponible et utilisée, version du système d'exploitation, etc.

La fonctionnalité attendue est la suivante :

* L'application écoute sur un port quelconque et répond aux requêtes HTTP sur un chemin précis (`http://localhost/api/v1/sysinfo`) ;
* Pour ce chemin, on retourne un objet (sérialisé en JSON) de la forme suivante :

  ```typescript
    interface ISystemInformation {
      cpu: si.Systeminformation.CpuData;
      system: si.Systeminformation.SystemData;
      mem: si.Systeminformation.MemData;
      os: si.Systeminformation.OsData;
      currentLoad: si.Systeminformation.CurrentLoadData;
      processes: si.Systeminformation.ProcessesData;
      diskLayout: si.Systeminformation.DiskLayoutData[];
      networkInterfaces: si.Systeminformation.NetworkInterfacesData[];
    }
  ```

* Pour tout autre chemin, on retournera une erreur 404.

### Déroulé

0. Mettez en place votre environnement de travail :
    - Créez votre dépôt GitHub à partir du [template fourni](https://github.com/khannurien/i-want-typescript) ;
    - [Installez Node.js](https://www.digitalocean.com/community/tutorials/how-to-install-node-js-on-ubuntu-20-04-fr) sur votre machine ;
    - Lisez le `README` fourni dans le template et réalisez les étapes nécessaires pour exécuter le code d'exemple, puis les tests unitaires associés.

1. Que pouvez-vous dire sur le fichier `package.json` ? Sur le fichier `package-lock.json` ?

2. Installez avec `npm` la bibliothèque `systeminformation`. Quel impact cette opération a-t-elle sur votre dépôt git ?

3. Écrivez l'application. Un soixantaine de lignes de code sont suffisantes à son fonctionnement : ne cherchez pas à généraliser. Découpez votre en quelques fonctions qui seront simples à tester par la suite. Quelles difficultés avez-vous rencontré ?

4. Testez le fonctionnement de votre application. Vous pouvez utiliser l'outil `curl`. À votre avis, pourquoi utilise-t-on ce formalisme pour construire l'URL de l'API ?

    ```shell
    curl http://localhost:8000/api/v1/sysinfo
    ```

4. Écrivez un jeu de test pour votre application, et vérifiez son exécution. Pourquoi écrit-on un tel jeu de tests ?

* https://docs.pact.io/ ?

## TD2 : conteneurisation avec Docker

### Objectif

Ce second TD introduit la notion d'**image** et de **conteneur** avec **Docker**.

Un conteneur est un mécanisme d'isolation léger qui s'appuie sur le noyau du système d'exploitation hôte.

Docker :

Image :

Pour construire votre image, vous allez vous appuyer sur la distribution Alpine Linux, destinée aux systèmes légers et souvent utilisée dans le contexte de la conteneurisation.

### Déroulé

0. Installez Docker et testez son fonctionnement :
  
    ```shell
    sudo apt update
    sudo apt install apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
    sudo apt update
    sudo apt install docker-ce
    # vérifiez le fonctionnement du daemon (sauf WSL2) :
    sudo systemctl status docker
    ```

    Si vous utilisez WSL2, vous aurez besoin de lancer le daemon à la main :

    ```shell
    sudo dockerd > /dev/null 2>&1 &
    # vérifiez le fonctionnement du daemon :
    sudo docker run hello-world
    ```

    Optionnellement, vous pouvez ajouter l'utilisateur courant au groupe `docker` pour utiliser Docker sans droits superutilisateur (donc sans `sudo` à chaque commande) :

    ```shell
    sudo usermod -aG docker ${USER}
    su - ${USER}
    ```

1. Écrivez votre première image dans un fichier nommé `Dockerfile` à la racine du dépôt de votre application. Voici un squelette de ce fichier, pour vous lancer :

    ```Dockerfile
    # image de départ
    FROM alpine:3.15

    # downgrade des privilèges

    # installation des paquets système

    # copie des fichiers du dépôt

    # installation des dépendances avec npm

    # build avec npm

    # exécution
    CMD ["node", "dist/index.js"]
    ```

2. Créez votre image à partir du `Dockerfile` :

    ```shell
    sudo docker build -t sysinfo-api:0.0.1 .
    ```

3. Créez un conteneur à partir de votre image :

    ```shell
    sudo docker run -p 8000:8000 sysinfo-api:0.0.1
    ```

    Puis testez votre application :

    ```shell
    curl http://localhost:8000
    curl http://localhost:8000/api/v1/sysinfo
    ```

4. Inspectez votre image, d'abord avec la CLI de Docker :

    ```shell
    sudo docker image history sysinfo-api:0.0.1
    ```

    Puis utilisez l'outil `dive` :

    ```shell
    wget https://github.com/wagoodman/dive/releases/download/v0.10.0/dive_0.10.0_linux_amd64.deb
    sudo apt install ./dive_0.10.0_linux_amd64.deb
    dive sysinfo-api:0.0.1
    ```

    Que remarquez-vous ?

5. Modifiez votre `Dockerfile` pour réaliser une construction *multi-stage* afin d'obtenir une image finale la plus légère possible, que vous taggerez à la version **0.0.2**. Quel delta constatez-vous en termes de taille ? Quelle(s) conséquence(s) cela pourrait-il avoir dans le contexte d'une application réelle ?

6. Vous allez maintenant pouvoir publier votre image Docker sur un dépôt (Docker Hub). Commencez par la tagger avec votre nom d'utilisateur (pas le mien :-)) :

    ```shell
    sudo docker tag sysinfo-api:0.0.2 khannurien/sysinfo-api:0.0.2
    ```

    Puis publiez-la :

    ```shell
    sudo docker login
    sudo docker push khannurien/sysinfo-api:0.0.2
    ```

## TD3 : CI/CD avec GitHub

* écriture du workflow ([documentation GitHub](https://docs.github.com/en/actions/automating-builds-and-tests/building-and-testing-nodejs-or-python))
* commit et test

* relisez la question 4 du TD1. Est-ce que ce TD3 vous permet d'enrichir votre réponse ?

## TD4 : déploiement sur PaaS avec Heroku

* installation de Heroku CLI (cf. [The Heroku CLI -- Heroku Dev Center](https://devcenter.heroku.com/articles/heroku-cli#download-and-install))
  
  ```shell
  curl https://cli-assets.heroku.com/install-ubuntu.sh | sh
  heroku --version
  ```

* connexion à Heroku

  ```shell
  heroku login
  ```

* connexion au Container Registry Heroku

  ```shell
  heroku container:login
  ```

* création de l'application Heroku

  ```shell
  heroku create
  ```

* publication de l'image Docker chez Heroku (TODO)

  ```shell
  docker tag sysinfo-api:0.0.1 registry.heroku.com/fathomless-tundra-66218/web
  docker push registry.heroku.com/fathomless-tundra-66218/web
  ```

* démarrage de l'application sur un noeud

  ```shell
  heroku container:release web
  ```

* visite de l'application : erreur ?

  ```shell
  heroku logs --tail
  ```

  ```
  2021-12-21T09:53:49.108685+00:00 heroku[web.1]: Error R10 (Boot timeout) -> Web process failed to bind to $PORT within 60 seconds of launch
  ```

* modification du code pour lire la variable `PORT` depuis l'environnement d'exécution
* recréation de l'image Docker
* démarrage de l'application

* [GitHub Integration (Heroku GitHub Deploys) -- Heroku Dev Center](https://devcenter.heroku.com/articles/github-integration#enabling-github-integration)

