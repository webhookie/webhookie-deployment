#!/bin/bash
. ../lib/lib.sh
info "🌟 Installing webhookie..."
NS="$1"

# shellcheck disable=SC3020
kubectl create ns "$NS" &> /dev/null

# Setup traefik!
#kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/v2.8/docs/content/reference/dynamic-configuration/kubernetes-crd-definition-v1.yml
#kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/v2.8/docs/content/reference/dynamic-configuration/kubernetes-crd-rbac.yml

run() {
  deploying "$1"
  kubectl "$command" -k . --namespace "$NS" 1>/dev/null
  installed "webhookie has been deployed successfully!"
}

delete() {
  run "Deleting Services"
}

apply() {
  run "Installing Services and Portal"
}

command="apply"

init() {
  while [ $# -gt 0 ]; do
    case "$2" in
    --delete)
      command="delete"
      ;;
    -d)
      command="delete"
      ;;
    --apply)
      command="apply"
      ;;
    -a)
      command="apply"
      ;;
    esac
    shift
  done
}

init "$@"
eval "$command"
