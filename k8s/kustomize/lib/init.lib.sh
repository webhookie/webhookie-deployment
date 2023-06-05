#!/bin/bash

kube_context=$(kubectl config current-context)
if [[ "$kube_context" == "" ]]; then
  LOG_ERROR "Please configure your k8s context with minikube or EKS"
  exit 1
fi
if [[ $kube_context == "minikube" ]]; then
  # shellcheck disable=SC1091
  . ./lib/minikube.lib.sh
fi
if [[ "$kube_context" = *"eksctl"* ]]; then
  # shellcheck disable=SC1091
  . ./lib/eks.lib.sh
fi

while [ $# -gt 0 ]; do
  case "$1" in
  --arm)
    log "Setting up for ARM architecture"
    arch="arm"
    ;;
  --auth=*)
    isKeycloak=false
    authFile="${1#*=}"
    if [ ! -f "services/$authFile" ]; then
      LOG_ERROR "$authFile not found!"
      exit 1
    fi
    LOG_INFO "Setting up auth from ${color_green}$authFile${color_reset}..."
    # shellcheck disable=SC1091
    . ./lib/auth.lib.sh
    ;;
  --with-demo)
    log "Setting up with Subscription Demo"
    runSample="true"
    ;;
  --with-monitoring)
    log "Setting up with Monitoring Enabled"
    monitoring="true"
    ;;
  --with-logging)
    log "Setting up with Logging Enabled"
    logging="true"
    ;;
  esac
  shift
done
