#!/bin/bash
set -e
# Ruta de tu repositorio local

LOG_FILE=(./Deploy.log)
DIR_FILE=(./direction_file.txt)
log() {
  local mensaje="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
  echo "$mensaje" | tee -a "$LOG_FILE"
}

LanzarContenedor() {
  if docker network ls | grep -q "convcourse-network"; then
    docker network create convcourse-network
  fi
  make build-prod
  make start-prod

  log "Contenedor creado con el Makefile"
}

ComprobarSiEsDistinto() {

  cd "$1" || exit 1

  BRANCH=$(git symbolic-ref --short HEAD)

  git fetch origin
  
  if git show-ref --verify --quiet "refs/remotes/origin/$BRANCH"; then
  
    LOCAL=$(git rev-parse "$BRANCH")
    REMOTE=$(git rev-parse "origin/$BRANCH")
  
    if [ "$LOCAL" != "$REMOTE" ]; then
      echo "Cambios detectados en $BRANCH. Haciendo pull..."
      git pull origin "$BRANCH"
      LanzarContenedor
    else
      echo "No hay cambios."
    fi
  
  else
    echo "La rama origin/$BRANCH no existe en remoto."
  fi

}

while IFS= read -r line
do

  ComprobarSiEsDistinto "$line"

done < DIR_FILE

