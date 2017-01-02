#!/bin/bash

# Ordena Daisy. Script que:
# 1. automaticamente detecta los archivos tipo daisy en ~/Downloads
# 2. Extrae los archivos a un directorio temporal
# 3. Detecta parametros daisy, como titulo y orden de los mp3.
# 4. Ordena los archivos mp3 y los copia en un directorio.
# 5. Genera una lista de reproduccion.
# Required for sed to work properly
export LC_CTYPE=C
export LANG=C
# CONSTANTES
TMP_DIR=/tmp/
OUT_DIR=$HOME/Documents/Libreria/
ITUNES_DIR="$HOME/Music/iTunes/iTunes Media/Automatically Add to iTunes.localized"
TITLE=""
ARTIST=""
ENCODING="utf8"

BOOK_DIR=""

function createPlaylist {
  echo "Creando Lista de Reproduccion: $1"
  ls "$1/*.mp3" > "$1/playlist.m3u"
}

function log {
  message=$2
  level=$1
  logger -t ordena-daisy -s -p $level "$message"
}

function debug {
  log debug "$1"
}

function info {
  log info "$1"
}

function error {
  log error "$1"
}


function title {
  TITLE=$(grep dc:title $1 | sed 's/.*content="\(.*\)".*/\1/' | iconv -f $ENCODING -t  ascii//translit | tr -cd '[[:alnum:]]._-\ ')
}
function artist {
  ARTIST=$(grep dc:creator $1 | sed 's/.*content="\(.*\)".*/\1/' | iconv -f $ENCODING -t ascii//translit | tr -cd '[[:alnum:]]._-\ ')
}

function encoding {
  ENCODING=$(grep encoding $1 | sed 's/.*encoding="\(.*\)".*/\1/')
  debug "ENCODING: $ENCODING"
}

function detectaDaisy {
  file=$1
  if [[ $file =~ \.zip$ ]]; then
    # Es un archivo zip. Vamos a ver si es un archivo daisy.
    # Debe de tener un archivo llamado ncc.html o ncc.htm
    unzip -l $file | grep ncc.htm > /dev/null
    if [ $? -eq 0 ]; then
      sleep 5
      info "Nuevo archivo daisy detectado. Iniciando extraccion."
      unzip -o $file -d $TMP_DIR > /dev/null
      if [ $? != 0 ]; then
        error "There was an error unzipping the file: $file. Exiting now."
        exit 1
      fi
      # TODO Verificar que la descompresion ha ido bien.
      dirname=$TMP_DIR`basename $file | cut -d. -f1`
      debug "Directorio: $dirname"
      nccFile="$(ls $dirname/ncc.htm*)"
      # Busca el titulo
      encoding "$nccFile"
      title "$nccFile"
      artist "$nccFile"
      debug "Titulo: $TITLE"
      debug "Artista: $ARTIST"
      # Crea el directorio de salida
      BOOK_DIR="$OUT_DIR$TITLE/"
      debug "Creando directorio de salida para el libro: $BOOK_DIR"
      mkdir -p "$BOOK_DIR"
      # Lista de archivos smil en ncc.html
      smilFiles=(`grep "smil" "$nccFile" | sed 's/.*href=\"\(.*\)#.*/\1/' | uniq`)
      debug "Lista de archivos smil: ${smilFiles[*]}"
      for i in ${!smilFiles[@]}; do
        smilFile="$dirname/${smilFiles[i]}"
        mp3File=`grep -m1 audio $smilFile | awk -F\" '{print $2}'`

        outFile=$BOOK_DIR`printf %03d $(($i+1))`".mp3"

        cp -f "$dirname/$mp3File" "$outFile"
        /usr/local/bin/id3v2 -a "$ARTIST" -A "$TITLE" "$outFile"
      done
      createPlaylist "$BOOK_DIR"
      # Importar en iTunes
      cp -r "$BOOK_DIR" "$ITUNES_DIR/$TITLE"
      # Borrar archivos temporales
      rm -rf $dirname
      info "Fin de extraccion de libro: $TITLE"
    fi

  fi
}



info "Nuevo archivo: $1"
detectaDaisy $1
