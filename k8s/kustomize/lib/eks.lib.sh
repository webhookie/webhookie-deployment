#!/bin/bash

isEKS=true

setKeycloakIngress "- keycloak-ingress.yml"

postInitCluster() {
  local name="ingress-nginx-controller"
  local ns="kube-system"
  host=$(kubectl get svc -n $ns | grep $name | grep LoadBalancer | awk '{print $4}' 2>/dev/null)
  url="$protocol_scheme://$host"
}

initCluster() {
  info "Current Cluster is running on ${color_green}EKS${color_reset}."

  local ns="kube-system"
  local resource="deployment"
  local controller="ingress-nginx-controller"
  local command="kubectl get $resource -n $ns $controller| grep -V Error | grep $controller"

  local status
  status=$(eval "$command" | awk '{print $2}' 2>/dev/null)
  if [[ $status == "" ]]; then
    deploying "Installing Nginx Ingress Controller...."
    helm upgrade --install ingress-nginx ingress-nginx \
        --repo https://kubernetes.github.io/ingress-nginx \
        --namespace kube-system &> /dev/null
    finished
  else
    info "Nginx Ingress Controller has been installed"
  fi

  postInitCluster
}

waitForCluster() {
  LOG_INFO "Waiting for the ${color_green}EKS${color_reset} Cluster..."
}
