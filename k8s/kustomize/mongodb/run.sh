#!/bin/bash
. ../lib/lib.sh
NS="$1"
LOG_INFO "🌟 Installing Mongodb..."

operator=crd/0.7.6

deployCRD() {
  declare instance
  instance=$(kubectl get crd/mongodbcommunity.mongodbcommunity.mongodb.com 2>/dev/null | grep mongodb | awk '{print $1}' &> /dev/null)
  # shellcheck disable=SC3020
  if [ -z "$instance" ]; then
    deploying "Installing MongoDB CRD"

    kustomize build ./$operator/config/crd | kubectl apply -f &> /dev/null -
    installed

    deploying "\t️⚡️ Verifying Mongodb CRD..."
    kubectl get crd/mongodbcommunity.mongodbcommunity.mongodb.com &> /dev/null
    installed
  else
    installed
  fi
}

deployRBAC() {
#  role=$(kubectl get role $operator --namespace "$NS" | grep mongodb | awk '{print $1}' &> /dev/null)
#  role_binding=$(kubectl get rolebinding $operator --namespace "$NS" | grep mongodb | awk '{print $1}' &> /dev/null)
#  service_account=$(kubectl get serviceaccount $operator --namespace "$NS" | grep mongodb | awk '{print $1}' &> /dev/null)

  deploying "Deploying Mongodb RBAC"
  # shellcheck disable=SC2069,SC3020
  kubectl create ns "$NS" &> /dev/null
  kustomize build ./$operator/config/rbac | kubectl apply --namespace "$NS" -f 1>/dev/null -
  installed
}

deployOperator() {
  deploying "Installing Mongodb Operator"
  kustomize build ./$operator/config/manager | kubectl apply --namespace "$NS" -f 1>/dev/null -
  installed
}

deployReplicaSet() {
  deploying "Deploying Mongodb replica set"
  kustomize build . | kubectl apply --namespace "$NS" -f 1>/dev/null -
  installed
}

deployOperatorUsingHelm() {
  deploying "Installing MongoDB Operator"
  kubectl create ns "$NS" &> /dev/null
  helm repo add mongodb https://mongodb.github.io/helm-charts &> /dev/null
  helm repo update &> /dev/null
  helm install community-operator mongodb/community-operator --namespace "$NS" &> /dev/null
  installed
}

# shellcheck disable=SC3020
pod_status=$(kubectl get po --namespace "$NS" 2>/dev/null | grep webhookie-mongodb | awk '{print $3}' &> /dev/null)
# shellcheck disable=SC3010
if [[ ${pod_status} == "Running" ]]; then
  ready "MongoDB is Running"
  exit 0
else
#  deployCRD
#  deployRBAC
#  deployOperator
  deployOperatorUsingHelm
  
  deployReplicaSet
  ready "MongoDB is Running"
fi
