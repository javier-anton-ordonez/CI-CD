#!/bin/bash
set -e
# Ruta de tu repositorio local
REPO_DIR=(
  "../BackEnd/"
  "../Website/"
  "."
)
LOG_FILE=(./Deploy.log)

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

  git fetch origin

  LOCAL=$(git rev-parse main)
  REMOTE=$(git rev-parse origin/main)

  if [ "$LOCAL" != "$REMOTE" ]; then
    log "Cambios detectados en main remoto. Haciendo pull..."
    git pull origin main

    LanzarContenedor
  else
    echo "$(date): No hay cambios."
  fi
}

for REPO in "${REPO_DIR[@]}"; do
  ComprobarSiEsDistinto "$REPO"

done
