#!/bin/bash
. ../lib/lib.sh
LOG_INFO "🌟 Installing RabbitMQ..."
NS="$1"

installOperator() {
  deploying "Installing RabbitMQ Operator"
  kubectl apply -f "https://github.com/rabbitmq/cluster-operator/releases/latest/download/cluster-operator.yml" 1>/dev/null
  installed "RabbitMQ Operator has been installed successfully!"
}

deploy() {
  deploying "Deploying RabbitMQ replica set"
  # shellcheck disable=SC3020
  kubectl create ns "$NS" &> /dev/null
  kubectl apply -k . --namespace "$NS" 1>/dev/null
  installed "RabbitMQ replica set has been deployed successfully!"
}

# shellcheck disable=SC3020
pod_status=$(kubectl get po --namespace "$NS" 2>/dev/null | grep webhookie-rabbitmq | awk '{print $3}' &> /dev/null)
# shellcheck disable=SC3010
if [[ ${pod_status} == "Running" ]]; then
  ready "RabbitMQ is Running"
  exit 0
else
  installOperator
  deploy
  ready "RabbitMQ is Running"
fi
