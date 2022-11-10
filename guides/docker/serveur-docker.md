---
title: Un serveur avec Docker
parent: Docker
grand_parent: Guides
published: false
---

# Un serveur avec Docker
{: .no_toc }

Dans ce guide, je vous propose d'utiliser Docker et Docker Compose pour déployer et orchestrer vos services sur un serveur.

<img align="center" src="./images/home-server.jpg" />

1. TOC
{:toc}

## Architecture

(figure)

* un VPN qui fonctionne sur le port HTTPS standard afin d'être accessible depuis n'importe quel réseau, même limité, et qui transfère au *reverse proxy* les requêtes HTTP qui lui sont destinées ;
* un *reverse proxy* pour traiter les requêtes HTTP passées par le VPN ;
* un ensemble de services, selon vos besoins, exposés par l'intermédiaire du reverse proxy :

## Pré-requis

Il voudra faudra un nom de domaine (optez pour [l'un](https://www.bookmyname.com/) [des](https://www.gandi.net/fr) [nombreux](https://www.namecheap.com/) [fournisseurs](https://www.ovhcloud.com/fr/domains/), parfois même [gratuit](https://www.dynu.com/)). Pour l'exemple, mon domaine sera `example.com`.

Faîtes pointer votre nom de domaine ainsi que tous ses sous-domaines vers votre adresse IP publique. La marche est à suivre diffère selon les fournisseurs (registrars), mais en gros, dans la configuration DNS de votre domaine, vous devrez créer deux enregistrements A de type :

| A | @             | 10.0.0.1 |
|---|---------------|----------|
| A | *.example.com | 10.0.0.1 |

@ correspond à la racine (c'est-à-dire "chezoim.com") chez la plupart des bureaux d'enregistrement.

Il faudra ouvrir deux ports sur votre routeur ou box : 80 (HTTP) et 443 (HTTPS). La marche à suivre dépend du modèle, mais [tout est documenté](https://fr.wikihow.com/ouvrir-des-ports).

Vous avez à votre disposition une machine GNU/Linux. Le guide fonctionne pour Ubuntu 22.10.

### Installation de Docker

On suit [la documentation](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository) :

```shell
# Update the apt package index and install packages to allow apt to use a repository over HTTPS:
sudo apt-get update
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker’s official GPG key:
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Use the following command to set up the repository:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update the apt package index:
sudo apt-get update

# Install Docker Engine, containerd, and Docker Compose.
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

Vérifiez que tout fonctionne correctement :

```shell
sudo docker run hello-world
```

## Préambule

Pour résumer, voici les images Docker que l'on va utiliser :

* Serveur VPN : [OpenVPN](https://hub.docker.com/r/kylemanna/openvpn) ;
* Reverse proxy : [Traefik](https://hub.docker.com/_/traefik) ;
* Base de données : [MariaDB](https://hub.docker.com/_/mariadb) ;
* Dashboard Docker : [Portainer](https://hub.docker.com/r/portainer/portainer-ce) ;
* Synchronisation et partage : [Nextcloud](https://hub.docker.com/r/linuxserver/nextcloud).

Puisque OpenVPN et Traefik vont écouter sur des ports réservés (443 et 80), un simple utilisateur ne pourra pas créer les conteneurs. On va donc passer en root avant d'effectuer la suite des manipulations.

## Démarrage

On crée un répertoire pour stocker la configuration des services :

```shell
sudo su
mkdir /home/docker
chmod 700 /home/docker
cd /home/docker
```

Docker propose de gérer des volumes nommés, par défaut stockés sous `/var/lib/docker/volumes`. C'est la solution que l'on va utiliser pour centraliser les données et la configuration des services.

## Définition des services

On crée le fichier `/home/docker/docker-compose.yml` avec la définition de l'ensemble de nos services. La configuration de Traefik est dynamique : on la passe à la création du conteneur. Les labels que l'on ajoute à chacun des conteneurs permettent à Traefik d'identifier les services et de créer les routes nécessaires.

Je me suis largement appuyé sur [un article du blog de Gérald Croës](https://traefik.io/blog/traefik-2-0-docker-101-fc2893944b9d/) que je vous recommande pour comprendre en détails le fonctionnement du reverse proxy.

Une note importante sur la version des images que vous choisissez : n'utilisez pas `latest` comme je le fais, par souci de simplification, dans l'exemple ci-dessous. Sélectionnez la dernière version stable et faîtes bien attention aux mises à jour. Par exemple, lorsque j'ai écrit ce guide, la version stable de Traefik était la `2.1`. Dans sa version `2.2`, la redirection globale vers HTTPS est [largement simplifiée](https://www.grottedubarbu.fr/traefik-2-2rc/).

```yaml
version: "3"

services:

volumes:

```

À noter qu'on utilise une authentification basique pour l'interface de Traefik. Pour générer un identifiant, utilisez la commande suivante – ici, l'utilisateur `toto` avec comme mot de passe `blabla` :

```shell
echo $(htpasswd -nbB toto "blabla") | sed -e s/\\$/\\$\\$/g
```

On sauvegarde également dans un volume le fichier `acme.json` qui contient nos certificats Let's Encrypt. Cela évite la mauvaise surprise d'atteindre les limites de renouvellement de certificats du service quand on fait ses tests...

## Configuration

### OpenVPN

On génère la configuration d'OpenVPN (TCP sur le port `443`, "partagé" avec Traefik) :

```shell
# générez la configuration qui permettra à OpenVPN de faire suivre les paquets arrivant sur son port d'écoute à Traefik
docker-compose run --rm openvpn ovpn_genconfig -u tcp://example.com:443 -e 'port-share traefik 443'

# rentrez un mot de passe solide et faîtes correspondre le Common Name demandé au nom d'hôte de votre serveur (i.e. le résultat de la commande hostname)
docker-compose run --rm openvpn ovpn_initpki
```

On peut prendre de l'avance et créer un certificat pour un client nommé `toto`. Le fichier `.ovpn` généré est auto-suffisant – vous pourrez l'importer dans n'importe quel client OpenVPN moderne :

```shell
docker-compose run --rm openvpn easyrsa build-client-full toto
docker-compose run --rm openvpn ovpn_getclient toto > toto.ovpn
```

### Nextcloud

On va créer les conteneurs pour initialiser leur configuration. Les volumes correspondant seront créés à la volée :

```shell
docker-compose up -d
```

Le cycle de vie d'un conteneur est court : on peut le détruire et le recréer comme on le souhaite, et il s'initialisera de la même manière à chaque lancement.

Il vous reste à accéder à Portainer et Nextcloud pour initialiser leur configuration. Pour Nextcloud, n'oubliez pas de préciser les informations sur la base de données. Le conteneur MariaDB et le conteneur Nextcloud sont connectés au même réseau, on peut donc compter sur Docker pour la résolution des noms et l'ouverture du port :

(figure)

Il est fort probable que la finalisation prenne trop de temps et que vous obteniez une erreur 504. Laissez passer quelques minutes, l'installation de Nextcloud se termine en tâche de fond.


## État des lieux

À ce stade, dans /home/docker, vous avez deux fichiers :

* `docker-compose.yml` qui définit les services à exécuter ;
* `toto.ovpn` qui est votre fichier de configuration pour un client OpenVPN.

Vos données sont stockées dans les volumes nommés définis par Docker Compose, sous le répertoire /var/lib/docker/volumes.

## Et ensuite ?

Mettez en place des sauvegardes – c'est simple, vous avez deux répertoires à surveiller :

* `/home/docker` qui contient la déclaration de vos services ;
* `/var/lib/docker/volumes` où se trouvent les volumes montés dans vos conteneurs, c'est-à-dire vos données.

N'oubliez pas de mettre à jour régulièrement les images de vos services :

```shell
docker-compose pull
docker-compose up -d
```

Au fur et à mesure, les versions antérieures des images peuvent être effacées pour récupérer de l'espace disque :

```shell
docker system prune
```

Enfin en cas de problème, consultez les journaux des conteneurs :

```shell
docker-compose logs
```

Pour garder un œil sur l'activité de vos conteneurs, je vous recommande [ctop](https://github.com/bcicen/ctop).