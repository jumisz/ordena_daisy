#!/bin/bash

BASE=$HOME/Library/ordena-daisy
echo "Installando Ordena Daisy en $BASE"
mkdir -p $BASE
echo "Copiando scripts en $BASE"
cp ordena-daisy.sh $BASE
cp run.sh $BASE
chmod a+x $BASE/*.sh
echo "Preparando la configuration de LaunchAgent"
cat ordena-daisy.agent.plist| sed s/%%USER%%/"$USER"/g > $HOME/Library/LaunchAgents/ordena-daisy.agent.plist
echo "Finalizado!"
