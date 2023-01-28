#!/bin/bash
. ../lib/lib.sh
LOG_INFO "🌟 Installing Monitoring Tools..."
NS="$1"

# shellcheck disable=SC3020
kubectl create ns "$NS" &> /dev/null

withKustomize() {
  deploying "Installing Prometheus and Grafana"
  kustomize build . | kubectl apply --namespace "$NS" -f 1>/dev/null -
  installed "Prometheus and Grafana have been installed successfully!"
}

withHelm() {
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
  helm repo update

  LOG_WARN -n 'admin' > ./admin-user
  LOG_WARN -n 'paxx1' > ./admin-password

  kubectl create secret generic webhookie-grafana-admin-credentials --from-file=./admin-user --from-file=admin-password -n "$NS"
  rm admin-user && rm admin-password
  helm install -n "$NS" webhookie-prometheus prometheus-community/kube-prometheus-stack -f values.yaml
}

withKustomize
