#!/bin/bash

# shellcheck disable=SC2034
isEKS=true

setKeycloakIngress "- keycloak-ingress.yml"

# bashsupport disable=BP2001
postInitCluster() {
  local name="ingress-nginx-controller"
  local ns="kube-system"
  host=$(kubectl get svc -n $ns | grep $name | grep LoadBalancer | awk '{print $4}' 2>/dev/null)
  # shellcheck disable=SC2034,SC2154
  url="$protocol_scheme://$host"
}

initCluster() {
  # shellcheck disable=SC2154
  LOG_INFO "Current Cluster is running on ${color_green}EKS${color_reset}."

  local ns="kube-system"
  local resource="deployment"
  local controller="ingress-nginx-controller"
  local command="kubectl get $resource -n $ns $controller| grep -V Error | grep $controller"

  local status message
  status=$(eval "$command" | awk '{print $2}' 2>/dev/null)
  message="Nginx Ingress Controller has been installed successfully!"
  if [[ $status == "" ]]; then
    deploying "Installing Nginx Ingress Controller...."
    helm upgrade --install ingress-nginx ingress-nginx \
        --repo https://kubernetes.github.io/ingress-nginx \
        --namespace kube-system &> /dev/null
    installed "$message"
  else
    installed "$message"
  fi

  postInitCluster
}

waitForCluster() {
  # shellcheck disable=SC2154
  LOG_INFO "Waiting for the ${color_green}EKS${color_reset} Cluster..."
}
