#!/bin/bash
# Get the name of the last modified file.
DOWNLOADS=$HOME/Downloads
newest=$(ls -U $DOWNLOADS/*.zip| head -1)
"$(dirname $0)/ordena-daisy.sh" "$newest"
