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

* [Traefik](https://hub.docker.com/_/traefik), un *reverse proxy* s'intercale entre Internet et les différents services que l'on souhaite exposer ;
* [OpenVPN](https://hub.docker.com/r/kylemanna/openvpn), un VPN configuré pour utiliser TCP, et qui écoute sur le port HTTPS standard, afin d'être accessible depuis n'importe quel réseau, même limité ;
* [Portainer](https://hub.docker.com/r/portainer/portainer-ce), un *dashboard* web pour Docker ;
* [Nextcloud](https://hub.docker.com/r/linuxserver/nextcloud), une plateforme de stockage (fichiers, photos...) et de partage (calendriers, contacts...) ;
* [MariaDB](https://hub.docker.com/_/mariadb), une base de données qui sera utilisée par Nextcloud.

## Pré-requis

1. Il voudra faudra un nom de domaine (optez pour [l'un](https://www.bookmyname.com/) [des](https://www.gandi.net/fr) [nombreux](https://www.namecheap.com/) [fournisseurs](https://www.ovhcloud.com/fr/domains/), parfois même [gratuit](https://www.dynu.com/)). Pour l'exemple, mon domaine sera `example.com`.

Faîtes pointer votre nom de domaine ainsi que tous ses sous-domaines vers votre adresse IP publique. La marche est à suivre diffère selon les fournisseurs (registrars), mais en gros, dans la configuration DNS de votre domaine, vous devrez créer deux enregistrements A de type :

| Type | Domaine       | Adresse  |
|------|---------------|----------|
| A    | @             | 10.0.0.1 |
| A    | *.example.com | 10.0.0.1 |

`@` correspond à la racine (c'est-à-dire *example.com*) chez la plupart des bureaux d'enregistrement. `10.0.0.1` correspond à l'[adresse IP publique](https://unix.stackexchange.com/a/194136/350724) obtenue par la box de votre opérateur.

2. Il faudra ouvrir deux ports sur votre routeur ou box : 80 (HTTP) et 443 (HTTPS). La marche à suivre dépend du modèle, mais [tout est documenté](https://fr.wikihow.com/ouvrir-des-ports).

3. Vous avez à votre disposition une machine GNU/Linux. Le guide fonctionne pour Ubuntu 22.04.

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

Puisque OpenVPN et Traefik vont écouter sur des ports réservés (443 et 80), un simple utilisateur ne pourra pas créer leurs conteneurs. On va donc passer en `root` avant d'effectuer la suite des manipulations.

## Démarrage

On crée un répertoire pour stocker la configuration des services :

```shell
sudo su
mkdir /var/stack
chmod 700 /var/stack
cd /var/stack
```

Docker propose de gérer des volumes nommés, par défaut stockés sous `/var/lib/docker/volumes`. C'est la solution que l'on va utiliser pour centraliser les données et la configuration des services.

## Définition des services

On crée le fichier `/var/stack/docker-compose.yml` avec la définition de l'ensemble de nos services.

La configuration de Traefik est dynamique : on la passe à la création du conteneur. Les labels que l'on ajoute à chacun des conteneurs permettent à Traefik d'identifier les services et de créer les routes nécessaires.



https://www.reddit.com/r/Traefik/comments/di6zds/openvpn_server_behind_traefik/
https://www.reddit.com/r/Traefik/comments/g6rr3f/openvpn_with_traefik_22_using_udp/
https://github.com/kylemanna/docker-openvpn/blob/1228577d4598762285958ad98724ab37e7b11354/docs/tcp.md
https://community.traefik.io/t/traefik-does-not-work-with-mariadb/13945




```yaml
version: '3'

services:
  traefik:
    image: traefik:v2.9
    command:
      - "--api"
      - "--providers.docker"
      - "--accesslog=true"
      - "--accesslog.filepath=/var/log/traefik.log"
      - "--pilot.dashboard=false"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.websecure.address=:443"
      - "--serverstransport.insecureskipverify=true"
      - "--entrypoints.web.http.redirections.entryPoint.to=websecure"
      - "--entrypoints.web.http.redirections.entryPoint.scheme=https"
      - "--entrypoints.web.http.redirections.entrypoint.permanent=true"
      - "--certificatesresolvers.letsencrypt.acme.caserver=https://acme-staging-v02.api.letsencrypt.org/directory"
      - "--certificatesresolvers.letsencrypt.acme.tlschallenge=true"
      - "--certificatesresolvers.letsencrypt.acme.email=toto@example.com"
      - "--certificatesresolvers.letsencrypt.acme.storage=/etc/traefik/acme/acme.json"
    restart: always
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /etc/timezone:/etc/timezone:ro
      - /etc/localtime:/etc/localtime:ro
      - traefik_logs:/var/log
      - traefik_certs:/etc/traefik/acme
    environment:
      - TZ=Europe/Paris
    labels:
      - "traefik.http.routers.traefik.rule=Host(`traefik.example.com`)"
      - "traefik.http.routers.traefik.service=api@internal"
      - "traefik.http.routers.traefik.tls.certresolver=letsencrypt"
      - "traefik.http.routers.traefik.entrypoints=websecure"
      - "traefik.http.routers.traefik.middlewares=admin"
      - "traefik.http.middlewares.admin.basicauth.users=toto:$$2y$$05$$LJ8gDZQN7puZmTM.OygwXu2uQQt1aTPDeA2uR6wExVSH6NRS0Ku8C"

  openvpn:
    cap_add:
     - NET_ADMIN
    image: kylemanna/openvpn:2.4
    restart: always
    depends_on:
      - "traefik"
    labels:
      #- "traefik.enable=true"
      - "traefik.tcp.services.openvpn.loadbalancer.server.port=443"
      - "traefik.tcp.routers.openvpn.rule=HostSNI(`*`)"
      - "traefik.tcp.routers.openvpn.entrypoints=websecure"
    volumes:
      - openvpn_data:/etc/openvpn

  portainer:
    image: portainer/portainer-ce:2.16
    command: -H unix:///var/run/docker.sock
    restart: always
    expose:
      - "8000"
      - "9000"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer_data:/data
    labels:
      - "traefik.http.services.portainer.loadbalancer.server.port=9000"
      - "traefik.http.routers.portainer.rule=Host(`portainer.example.com`)"
      - "traefik.http.routers.portainer.tls=true"
      - "traefik.http.routers.portainer.tls.certresolver=letsencrypt"
      - "traefik.http.routers.portainer.entrypoints=websecure"

volumes:
  traefik_logs:
  traefik_certs:
  openvpn_data:
  portainer_data:

```

À noter qu'on utilise une authentification basique pour l'interface web de Traefik. Pour générer un identifiant, utilisez la commande suivante – ici, l'utilisateur `toto` avec comme mot de passe `blabla` :

```shell
echo $(htpasswd -nbB toto "blabla") | sed -e s/\\$/\\$\\$/g
```

On sauvegarde également dans un volume le fichier `acme.json` qui contient nos certificats Let's Encrypt. Cela évite la mauvaise surprise d'atteindre les limites de renouvellement de certificats du service quand on fait ses tests...

## Configuration

### OpenVPN

On génère la configuration d'OpenVPN (TCP sur le port `443`, "partagé" avec Traefik) :

```shell
# générez la configuration du serveur OpenVPN pour utiliser TCP
docker-compose run --rm openvpn ovpn_genconfig -u tcp://vpn.example.com:443

# rentrez un mot de passe solide et faîtes correspondre le Common Name demandé au nom d'hôte de votre serveur (i.e. le résultat de la commande hostname)
docker-compose run --rm -it openvpn ovpn_initpki
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

À ce stade, dans `/var/stack`, vous avez deux fichiers :

* `docker-compose.yml` qui définit les services à exécuter ;
* `toto.ovpn` qui est votre fichier de configuration pour un client OpenVPN.

Vos données sont stockées dans les volumes nommés définis par Docker Compose, sous le répertoire /var/lib/docker/volumes.

## Et ensuite ?

Mettez en place des sauvegardes – c'est simple, vous avez deux répertoires à surveiller :

* `/var/stack` qui contient la déclaration de vos services ;
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
