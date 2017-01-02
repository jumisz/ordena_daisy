#!/bin/bash
# Get the name of the last modified file.
DOWNLOADS=$HOME/Downloads
newest=$(ls -U $DOWNLOADS| head -1)
echo "$@"
"$(dirname $0)/ordena-daisy.sh" "$DOWNLOADS/$newest"
