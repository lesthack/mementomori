#!/bin/bash

echo "MementoMori - By Jorge Hernández"

# Uso
# 1. Hacer commit prime día de la semana de la fecha actual
# ./mementomori -c "mementomori"
# 2. Hacer commits desde la fecha de nacimiento
# ./mementomori -b 1986-08-11

if [ $# -eq 0 ]; then
    echo "O.O?"
    exit 0
fi

get_random_phrase() {
  phrases='./phrases.md'
  num_lineas=$(wc -l < "$phrases")
  linea_random=$((RANDOM % num_lineas + 1))
  linea=$(awk "NR==$linea_random" "$phrases")
  echo $linea
}

do_commits_from() {
    # Parámetro: fecha en formato YYYY-MM-DD
    fecha_inicial=$1

    # Validación del formato de la fecha usando una expresión regular
    if [[ ! $fecha_inicial =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        echo "Formato de fecha incorrecto. Use YYYY-MM-DD."
        return 1
    fi

    # Intentamos convertir la fecha inicial a segundos desde el epoch
    fecha_inicial_segundos=$(date -d "$fecha_inicial" +%s 2>/dev/null)
    if [ $? -ne 0 ]; then
        echo "Fecha inválida."
        return 1
    fi

    # Fecha actual en segundos desde el epoch
    fecha_actual_segundos=$(date +%s)

    # Generar y mostrar las fechas semanales desde la fecha inicial hasta la actual
    fecha_actual="$fecha_inicial"
    while [ $(date -d "$fecha_actual" +%s) -le $fecha_actual_segundos ]; do
        year=$(echo $fecha_actual | cut -d'-' -f1)
        if [ ! -d "$year" ]; then
          mkdir $year
        fi
        phrase="$(get_random_phrase)"
        echo "$phrase" > $year/$fecha_actual.md
        git add $year/$fecha_actual.md
        GIT_AUTHOR_DATE="$fecha_actual 12:00:00" GIT_COMMITTER_DATE="$fecha_actual 12:00:00" git commit -m "$phrase"
        ## Avanzar 7 días (una semana)
        fecha_actual=$(date -d "$fecha_actual + 7 days" +%Y-%m-%d)
    done
}

while getopts "cb:" opt; do
    case $opt in
        c)
            do_commits_from $(date +%Y-%m-%d)
            ;;
        b)
            do_commits_from $OPTARG
            ;;
        *)
            echo "Opción inválida: -$OPTARG" >&2
            exit 1
            ;;
    esac
done
