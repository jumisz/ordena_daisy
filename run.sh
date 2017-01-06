#!/bin/bash
# Get the name of the last modified file.
DOWNLOADS=$HOME/Downloads
# Esperar 2 segundos por si el sistema no ha terminado de convertir la
# descarga en ZIP
sleep 2s
echo "Ultimos archivos: $(ls -tU $DOWNLOADS/*.zip| head -3)"
newest=$(ls -tU $DOWNLOADS/*.zip| head -1)
"$(dirname $0)/ordena-daisy.sh" "$newest"
