#!/usr/bin/env sh

echo "$USER"
echo "$HOME"

pwd

cd "$HOME"

# Téléchargez le fichier suivant:
# https://khannurien.github.io/labs/linux/resources/ex1.txt
wget "https://khannurien.github.io/labs/linux/resources/ex1.txt"


cat << EOT >> lol.txt
bla
blabla
EOT
