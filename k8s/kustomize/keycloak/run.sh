#!/bin/bash
. ../lib/lib.sh
LOG_INFO "🌟 Installing Keycloak..."

NS="$1"
ARCH="$2"
# shellcheck disable=SC3020
kubectl create ns "$NS" &> /dev/null

command="apply"

init() {
  while [ $# -gt 0 ]; do
    case "$3" in
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
kubectl "$command" --namespace "$NS" -k "$ARCH" 1>/dev/null
# shellcheck disable=SC3010
if [[ ${command} == "apply" ]]; then
  ready "Keycloak is Running"
fi
