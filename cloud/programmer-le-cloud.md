# Programmer le Cloud

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

![Use this template](./images/github-template.png "Use this template")

La fonctionnalité attendue est la suivante :

* L'application écoute sur un port quelconque et répond aux requêtes HTTP sur un chemin précis (`http://localhost/api/v1/sysinfo`) ;
* Elle retourne un objet (sérialisé en JSON) de la forme suivante :

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

### Déroulé

0. Mettez en place votre environnement de travail :
    - Créez votre dépôt GitHub à partir du [template fourni](https://github.com/khannurien/i-want-typescript) ;
    - [Installez Node.js](https://www.digitalocean.com/community/tutorials/how-to-install-node-js-on-ubuntu-20-04-fr) sur votre machine ;
    - Lisez le `README` fourni dans le template et réalisez les étapes nécessaires pour exécuter le code d'exemple, puis les tests unitaires associés.

1. Que pouvez-vous dire sur le fichier `package.json` ? Sur le fichier `package-lock.json` ?

2. Installez avec `npm` la bibliothèque `systeminformation`. Quel impact cette opération a-t-elle sur votre dépôt git ?

3. Écrivez l'application. Un soixantaine de lignes de code sont suffisantes à son fonctionnement : ne cherchez pas à généraliser. Découpez votre en quelques fonctions qui seront simples à tester par la suite.

4. Testez le fonctionnement de votre application. Vous pouvez utiliser l'outil `curl` :

    ```shell
    curl http://localhost:8000
    ```

4. Écrivez un jeu de test pour votre application, et vérifiez son exécution.

* https://docs.pact.io/ ?

## TD2 : conteneurisation avec Docker

* installation de Docker (cf. [Comment installer et utiliser Docker sur Ubuntu 20.04 -- DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04-fr))
  
  ```shell
  sudo apt update
  sudo apt install apt-transport-https ca-certificates curl software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
  sudo apt update
  sudo apt install docker-ce
  sudo systemctl status docker
  ```

* (WSL2) démarrage du daemon et test
  
  ```shell
  sudo dockerd > /dev/null 2>&1 &
  sudo docker run hello-world
  ```

* (optionnel) ajout de l'utilisateur courant au groupe `docker` pour utilisation sans `sudo` :

  ```shell
  sudo usermod -aG docker ${USER}
  su - ${USER}
  ```

* écriture du `Dockerfile`

* création de l'image

  ```shell
  sudo docker build -t sysinfo-api:0.0.1 .
  ```

* création d'un conteneur à partir de notre image

  ```shell
  sudo docker run -p 8000:8000 sysinfo-api:0.0.1
  ```

* test de l'API avec `curl`

  ```shell
  curl localhost:8000
  ```

* inspection de l'image

  ```shell
  sudo docker image history sysinfo-api:0.0.1
  ```

  ```shell
  wget https://github.com/wagoodman/dive/releases/download/v0.10.0/dive_0.10.0_linux_amd64.deb
  sudo apt install ./dive_0.10.0_linux_amd64.deb
  dive sysinfo-api:0.0.1
  ```

* modification du code et mise-à-jour de l'image

* tag de l'image au nom de l'auteur pour le dépôt Docker

  ```shell
  sudo docker tag sysinfo-api:0.0.1 khannurien/sysinfo-api:0.0.1
  ```

* publication de l'image

  ```shell
  sudo docker login
  sudo docker push khannurien/sysinfo-api:0.0.1
  ```

## TD3 : CI/CD avec GitHub

* écriture du workflow ([documentation GitHub](https://docs.github.com/en/actions/automating-builds-and-tests/building-and-testing-nodejs-or-python))
* commit et test

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

