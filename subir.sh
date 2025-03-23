# Este script es para pushear al GitHub, para ahorrarse tener que escribir los comandos a cada rato.

DEST="$HOME/Cuda-en-NixOS"





cd "$DEST"
git add .


echo "Mensaje del commit:"
read MENSAJE

git commit -S -m "$MENSAJE"
git push origin main