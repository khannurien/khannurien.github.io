# Programmer le Cloud
{: .no_toc }

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

Votre application devra être accessible par le web et capable de donner des informations concernant le système sur lequel elle s'exécute : nombre de cœurs de processeur et charge actuelle, quantité de mémoire disponible et utilisée, version du système d'exploitation, etc.

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

3. Écrivez l'application. Un soixantaine de lignes de code sont suffisantes à son fonctionnement : ne cherchez pas à généraliser. Découpez votre code en quelques fonctions qui seront simples à tester par la suite. Quelles difficultés avez-vous rencontrées ?

4. Testez le fonctionnement de votre application. Vous pouvez utiliser l'outil `curl`. À votre avis, pourquoi utilise-t-on ce formalisme pour construire l'URL de l'API ?

    ```shell
    curl http://localhost:8000
    curl http://localhost:8000/api/v1/sysinfo
    ```

4. Écrivez un jeu de test pour votre application, et vérifiez son exécution. Pourquoi écrit-on un tel jeu de tests ?

* https://docs.pact.io/ ?

## TD2 : conteneurisation avec Docker

### Objectif

Ce second TD introduit la notion d'**image** et de **conteneur** avec **Docker**. L'idée est de déporter l'exécution de votre application dans un processus isolé du reste du système. Ce processus sera initialisé à partir d'une image disque qui contiendra l'ensemble des dépendances nécessaires à l'exécution.

Un conteneur est un mécanisme d'isolation léger qui s'appuie sur le noyau du système d'exploitation hôte. Du point du vue du programme qui s'y exécute, la plateforme semble être un système complet. Néanmoins, les ressources qui lui sont allouées constituent un sous-ensemble virtualisé des ressources disponibles sur la machine hôte.

Docker est en réalité une suite d'outils :
* `dockerd` est un daemon qui fournit une API et une CLI, capable de construire les images, distribuables, qui représentent l'état initial d'un conteneur. C'est l'interface de haut niveau avec laquelle vous allez communiquer dans ce projet ;
* `containerd`, initiative de la CNCF, gère le cycle de vie d'un conteneur (hypervision, exécution avec `runc`) et est responsable de la gestion des images (push, pull), du stockage et du réseau -- c'est-à-dire d'établir un lien entre les namespaces des différents conteneurs ;
* `containerd-shim` est un processus intermédiaire qui restera le processus père d'un conteneur durant toute son exécution. Il maintient la liste des descripteurs de fichiers ouverts par le conteneur (à commencer par `stdio`). Cela permet de maintenir un lien avec le conteneur dans le cas où `containerd` est arrêté. Par ailleurs, il est responsable de remonter le code de sortie d'un conteneur au niveau supérieur ;
* `runc` implémente la [spécification OCI](https://github.com/opencontainers/runtime-spec) et contient le code permettant l'exécution d'un conteneur. Il crée et démarre le conteneur, et termine son exécution.

![Docker breakdown](./images/docker-breakdown.png "Docker breakdown")
[Avijit Sarkar](https://medium.com/@avijitsarkar123/docker-and-oci-runtimes-a9c23a5646d6)

Dans l'écosystème Docker, une image correspond à une "recette" décrite dans un fichier, communément nommé `Dockerfile`, qui, au même titre qu'un `Makefile` pour `make` donne une suite d'instructions à la machine pour produire un binaire de l'application, donne ici la marche à suivre pour produire un conteneur qui comprendra l'application et son environnement d'exécution.

La base de tout conteneur Docker est un système d'exploitation : pour construire une image de votre application, vous allez vous appuyer sur la distribution **Alpine Linux**, destinée aux systèmes légers et souvent utilisée dans le contexte de la conteneurisation.

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

    # chemin de travail
    WORKDIR ...

    # downgrade des privilèges
    USER ...

    # installation des paquets système
    RUN ...

    # copie des fichiers du dépôt
    COPY ...

    # installation des dépendances avec npm
    RUN ...

    # build avec npm
    RUN ...

    # exécution
    CMD ...
    ```

    [La documentation](https://docs.docker.com/engine/reference/builder/) fournit des explications détaillées sur les instructions à votre disposition.

2. Créez votre image à partir du `Dockerfile` :

    ```shell
    sudo docker build -t sysinfo-api:0.0.1 .
    ```

3. Créez un conteneur à partir de votre image. À quoi sert le flag `-p` ? Le flag `-m` ? Le flag `--cpus` ? Pour ces deux derniers, faîtes varier les valeurs pour constater leur impact sur la sortie de votre application.

    ```shell
    sudo docker run -p 8123:8000 -m1024m --cpus=1 sysinfo-api:0.0.1
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

    Que remarquez-vous ? À votre avis, comment pourrait-on réduire la taille de l'image produite ?

5. Modifiez votre `Dockerfile` pour réaliser une [construction *multi-stage*](https://docs.docker.com/develop/develop-images/multistage-build/) afin d'obtenir une image finale la plus légère possible, que vous taggerez à la version **0.0.2**. Quel delta constatez-vous en termes de taille ? Quelle(s) conséquence(s) cela pourrait-il avoir dans le contexte d'une application réelle ?

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

### Objectif

Les opérations d'intégration continue (**CI**, pour *Continuous Integration*) et de livraison continue (**CD**, pour *Continuous Delivery*) sont à la base des pratiques DevOps. L'idée est d'avoir, à tout moment du cycle de vie d'une application, une *codebase* dans un état fonctionnel. Il s'agit, d'une part, de s'assurer qu'aucune régression n'est introduite par une évolution dans le code, et d'autre part, que le produit est toujours en état d'être compilé.

À ces fins, nous allons faire en sorte d'exécuter automatiquement la suite de tests de l'application à chaque *commit* sur le dépôt Git. Si les tests passent au vert, alors l'image Docker de l'application sera elle aussi reconstruite et publiée dans la foulée.

L'environnement d'exécution pour les tests est fourni par GitHub dans le cadre de leur produit *Actions*. C'est un conteneur Docker que vous configurez de manière déclarative, au travers d'un fichier YAML qui décrira l'événement déclencheur, les propriétés de l'environnement d'exécution, les actions à réaliser...

Ces fichiers *action* peuvent être mobilisés dans le cadre d'une composition appelée *workflow* : les actions sont alors exécutées séquentiellement, ce qui permet de décrire des environnements d'exécution complexes. Vous pouvez regarder [l'action *Setup Node*](https://github.com/actions/setup-node) fournie par GitHub.

### Déroulé

0. Suivez [le tutoriel de *GitHub Actions*](https://docs.github.com/en/actions/quickstart) pour écrire votre premier *workflow*.

1. Inspirez-vous du *workflow* que vous avez écrit dans le cadre du tutoriel pour correspondre aux exigences suivantes :

    * lors d'un *push* sur la branche `main` de votre dépôt ;
    * installer Node dans la même version que vous utilisez pour développer ;
    * installer les dépendances de votre application ;
    * compiler l'application et exécuter la suite de tests unitaires.

2. Une fois votre *workflow* écrit, testez-le. Comment vérifiez-vous son fonctionnement ?

3. Relisez la question 4 du TD1. Est-ce que ce TD3 vous permet d'enrichir votre réponse ?

## TD4 : déploiement sur PaaS avec Heroku

### Objectif

Pour cette dernière étape, nous allons nous intéresserau **déploiement** de notre application, c'est-à-dire sa *mise en production* sur une plateforme cible.

Vous allez d'abord déployer votre application à la main, afin de vous familiariser avec le processus. Puis vous ferez en sorte d'automatiser cette dernière étape pour atteindre l'objectif du **déploiement continu**.

### Déroulé

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

* que pouvez-vous dire sur la machine qui exécute votre code ? Remarquez-vous des éléments intéressants ?

* [GitHub Integration (Heroku GitHub Deploys) -- Heroku Dev Center](https://devcenter.heroku.com/articles/github-integration#enabling-github-integration)

