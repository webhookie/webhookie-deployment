#!/bin/bash

declare -r default_size="medium"
declare version="latest"
declare command="up"
declare keycloak_image="quay.io/keycloak/keycloak:14.0.0"
declare auth_provider="keycloak"
declare help="false"
declare branding_path="./data/branding"
declare branding_color=""

declare sizes=(
  "small"
  "medium"
  "large"
  "x-large"
)

declare modules=(
  "mongo"
  "rabbit"
  "services"
  "gateway"
  "portal"
  "nginx"
)

init() {
  while [ $# -gt 0 ]; do
    case "$1" in
    --beta)
      version="beta"
      ;;
    --help)
      help="true"
      ;;
    --size=*)
      size="${1#*=}"
      ;;
    --branding=*)
      branding_path="${1#*=}"
      ;;
    --branding-color=*)
      branding_color="${1#*=}"
      ;;
    --dry-run)
      command="config"
      ;;
    --config)
      command="config"
      ;;
    --down)
      command="down"
      ;;
    --up)
      command="up"
      ;;
    --arm)
      keycloak_image="wizzn/keycloak:14"
      ;;
    --auth0)
      auth_provider="auth0"
      ;;
    --with-logging)
      modules+=("logging")
      ;;
    --with-monitoring)
      modules+=("monitoring")
      ;;
    --with-demo)
      modules+=("sample")
      ;;
    --no-mongo)
      modules=("${modules[@]/"mongo"}")
      ;;
    --no-rabbit)
      modules=("${modules[@]/"rabbit"}")
      ;;
    --no-portal)
      modules=("${modules[@]/"portal"}")
      ;;
      #    *)
      #      printf "***************************\n"
      #      printf "* Error: Invalid argument.*\n"
      #      printf "***************************\n"
      #      exit 1
    esac
    shift
  done

  if [[ $(arch) == 'arm64' ]]; then
    keycloak_image="wizzn/keycloak:14"
  fi

  if [[ $size == "" ]]; then
    size=$default_size
  fi

  if [[ ${sizes[*]} =~ (^|[[:space:]])"$size"($|[[:space:]]) ]]; then
    if [ "$help" == "true" ]; then
      show_help
    else
      run
    fi
  else
    echo "$size is not a valid Size!"
    # shellcheck disable=SC2128
    echo "please select from ${sizes[*]}"
    exit 1
  fi
}

run () {
  {
    cat ./elk.env
    cat ./res/env.res."$size"
    echo "WEBHOOKIE_BRANDING_PATH=$branding_path"
    echo "WEBHOOKIE_TAG=$version"
    echo "KEYCLOAK_IMAGE=$keycloak_image"
    echo "AUTH_ENV=./data/$auth_provider.env"
  } > ./.env

  if [[ $auth_provider == "keycloak" ]]; then
    modules+=("keycloak")
  fi

  if [[ $branding_color != "" ]]; then
    echo "WEBHOOKIE_BRANDING_COLOR='$branding_color'" >> ./.env
  else
    echo "WEBHOOKIE_BRANDING_COLOR=" >> ./.env
  fi

  declare compose=""
  for module in "${modules[@]}"; do
    if [ "$module" != "" ]; then
      compose="$compose -f docker-$module.yml"
    fi
  done

  eval "docker compose $compose $command"
}

show_help() {
  printf "./run without any parameter brings all services with default values\n"
  printf "default values:\n"
  printf "\t size: medium; could be small, medium, large, x-large\n"
  printf "\t version: latest; could be beta, latest\n"
  printf "\t command: up; could be up, config, down\n"
  printf "\t auth_provider: keycloak\n"
  echo "--beta: runs beta version of all webhookie-services"
  echo "--help: shows this page"
  echo "--size=[small/medium/large/x-large]: sets resource reservations and limits for the services"
  echo "--dry-run: shows full compose file with the current values"
  echo "--config: alias for --dry-run"
  echo "--down: brings services down"
  echo "--up: brings services up"
  echo "--arm: uses arm keycloak image for M1 Macs"
  echo "--auth0: removes keycloak from the stack and sets auth0 as auth provider; consider having auth0.env file in the same folder as keycloak.env"
  echo "--with-logging: adds ELK containers from the deployment"
  echo "--with-monitoring: adds Monitoring(Prometheus and Grafana) containers from the deployment"
  echo "--with-demo: adds Sample subscription application container from the deployment"
  echo "--no-mongo: removes MongoDB container from the deployment; consider updating env variables"
  echo "--no-rabbit: removes RabbitMQ container from the deployment; consider updating env variables"
  echo "--no-portal: removed webhookie-portal from the deployment"
  echo "--no-registry: removed Eureka from the deployment"
  echo "--branding: points to your own branding folder if you want to re-brand webhookie!"
  echo "--branding-color: updates webhookie portal with the given color as the main color"
}

init "$@"

