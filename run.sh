#!/bin/bash
# Get the name of the last modified file.
DOWNLOADS=$HOME/Downloads
newest=$(ls -t  $DOWNLOADS| head -1)
"$(dirname $0)/ordena-daisy.sh" "$DOWNLOADS/$newest"
