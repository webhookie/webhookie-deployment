#!/bin/bash

isMinikube=true

portForward() {
  declare NS="$1"
  declare SERVICE="$2"
  declare localPort=$3
  declare servicePort=$4

  local message="Port-Forward to '$NS' -> '$SERVICE' from $servicePort(host) to $localPort(local)"
  LOG_INFO "$message"

  # shellcheck disable=SC2086,SC2069
  kubectl port-forward -n "$NS" service/"$SERVICE" $localPort:$servicePort &> /dev/null &
  installed "$localPort:$servicePort port forwarded successfully!"
#  kubectl port-forward -n "$NS" service/"$SERVICE" $localPort:$servicePort > /dev/null 2>&1 &
}

postInitCluster() {
  LOG_INFO "Minikube has been initialized"
}

initCluster() {
  LOG_INFO "Current Cluster is running on ${color_green}minikube${color_reset}."
  setKeycloakIngress ""

  if [[ $(arch) == 'arm64' ]]; then
    arch="arm"
    # shellcheck disable=SC2034
    isArm=true
  fi

  deploying "Installing ingress addon"
  #ingress_status=$(minikube addons list -o json | jq '.ingress.Status')
  minikube addons enable ingress &> /dev/null
  installed "Ingress addon has been installed successfully!"
}

waitForCluster() {
  LOG_INFO "Current Cluster is running on minikube."
  waitForInput "*** Please open a new terminal and run 'minikube tunnel' command and keep that terminal open\n"
}
