#!/bin/bash
. ../lib/lib.sh
LOG_INFO "🌟 Installing ELK Stack..."

declare -r NS=$1
declare -r ECK_VERSION="2.4.0"
declare ES_PASSWORD=""
declare command="apply"
es_pod_status=$(kubectl get po -n "$NS" 2>/dev/null | grep webhookie-elasticsearch | awk '{print $3}' &> /dev/null)

init() {
  while [ $# -gt 0 ]; do
    case "$2" in
    --deploy)
      command="deploy"
      ;;
    -d)
      command="deploy"
      ;;
    --pass)
      command="passwd"
      ;;
    -p)
      command="passwd"
      ;;
    esac
    shift
  done
}

init "$@"

kubectl create ns "$NS" &> /dev/null

installCRD() {
  declare agent message
  agent=$(kubectl get customresourcedefinition.apiextensions.k8s.io/agents.agent.k8s.elastic.co 2>/dev/null | grep elastic | awk '{print $1}' &> /dev/null)
  message="elastic.co agent has been installed successfully!"
  if [ -z "$agent" ]; then
    deploying "Installing Elastic CRD"
    kubectl create -f "https://download.elastic.co/downloads/eck/$ECK_VERSION/crds.yaml"  &> /dev/null
    installed "$message"
  else
    installed "$message"
  fi
}

installOperator() {
  deploying "Installing Elastic Operator"
  kubectl apply -f "https://download.elastic.co/downloads/eck/$ECK_VERSION/operator.yaml" 1>/dev/null
  installed "Elastic Operator has been installed successfully!"
}

deployReplicaSet() {
  deploying "Deploy Elasticsearch replica set"
  kustomize build . | kubectl apply -n "$NS" -f 1>/dev/null -
  installed "Elasticsearch replica set has been deployed successfully!"
}

passwd() {
  ES_PASSWORD=$(kubectl get secret webhookie-elasticsearch-es-elastic-user -n "$NS" -o go-template='{{.data.elastic | base64decode}}')
  # bashsupport disable=BP2002
  LOG_WARN "Elasticsearch is Running. elasticsearch pass: %s \n" "$ES_PASSWORD"
}

portForward() {
  nohup kubectl port-forward -n "$NS" "service/$1" "$2" &
}

openUI() {
  LOG_WAIT "$es_pod_status"
  if [[ ${es_pod_status} == "Running" ]]; then
    passwd
    portForward "webhookie-kibana-kb-http" 5601
    open https://localhost:5601
  else
    ready "ELK is NOT Running. Make sure you have elk running in the same namespace.\n"
  fi
}

deploy() {
  if [[ ${es_pod_status} == "Running" ]]; then
    ready "ELK is Running"
  else
    installCRD
    installOperator
    deployReplicaSet
    ready "ELK is Running"
  fi
}

if [[ ${command} == "deploy" ]]; then
  deploy
else
  if [[ ${command} == "passwd" ]]; then
    passwd
  else
    openUI
  fi
fi
