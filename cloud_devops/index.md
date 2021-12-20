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

* [Installer WSL 2 | Microsoft Docs](https://docs.microsoft.com/fr-fr/windows/wsl/install)

Les instructions du TD seront données pour Ubuntu 20.04 (qui est notamment la distribution par défaut pour WSL2). **Vous êtes responsable de votre environnement de développement** : si vous n'êtes pas certain-e de le maîtriser, alignez-vous sur ce choix, qui vous permettra de gagner du temps sur les aspects opérationnels du projet.

## TD1 : une application Node.js

* installation de Node.js
  
  * [Comment installer Node.js sur Ubuntu 20.04 | DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-install-node-js-on-ubuntu-20-04-fr)

* création du dépôt git
  
  * [GitHub - khannurien/i-want-typescript: 📜 Template repository for a new Node.js TypeScript project linted using ESLint with Prettier](https://github.com/khannurien/i-want-typescript)

* inspection de `package.json`

* installation de `systeminformation` comme dépendance

* écriture du jeu de test

* écriture de la fonction `getSystemInformation`

* initialisation du serveur HTTP

* mise-à-jour du jeu de test ?

* https://docs.pact.io/ ?

## TD2 : conteneurisation avec Docker

* installation de Docker (cf. [Comment installer et utiliser Docker sur Ubuntu 20.04 | DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04-fr))
  
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

* bla

## TD3 : CI/CD avec GitHub

* bla

## TD4 : déploiement sur PaaS avec Heroku

* installation de Heroku CLI (cf. [The Heroku CLI | Heroku Dev Center](https://devcenter.heroku.com/articles/heroku-cli#download-and-install))
  
  ```shell
  curl https://cli-assets.heroku.com/install-ubuntu.sh | sh
  heroku --version
  ```

* [GitHub Integration (Heroku GitHub Deploys) | Heroku Dev Center](https://devcenter.heroku.com/articles/github-integration#enabling-github-integration)

* bla
