#!/bin/bash
. ../lib/lib.sh
NS="$1"
LOG_INFO "🌟 Installing Mongodb..."

operator=crd/0.7.6

deployCRD() {
  declare instance message
  instance=$(kubectl get crd/mongodbcommunity.mongodbcommunity.mongodb.com 2>/dev/null | grep mongodb | awk '{print $1}' &> /dev/null)
  message="MongoDB CRD has been installed successfully!"
  # shellcheck disable=SC3020
  if [ -z "$instance" ]; then
    deploying "Installing MongoDB CRD"

    kubectl apply -k ./$operator/config/crd &> /dev/null

    deploying "\t️⚡️ Verifying Mongodb CRD..."
    kubectl get crd/mongodbcommunity.mongodbcommunity.mongodb.com &> /dev/null
    installed "$message"
  else
    installed "$message"
  fi
}

deployRBAC() {
#  role=$(kubectl get role $operator --namespace "$NS" | grep mongodb | awk '{print $1}' &> /dev/null)
#  role_binding=$(kubectl get rolebinding $operator --namespace "$NS" | grep mongodb | awk '{print $1}' &> /dev/null)
#  service_account=$(kubectl get serviceaccount $operator --namespace "$NS" | grep mongodb | awk '{print $1}' &> /dev/null)

  deploying "Deploying Mongodb RBAC"
  # shellcheck disable=SC2069,SC3020
  kubectl create ns "$NS" &> /dev/null
  kubectl apply -k ./$operator/config/rbac --namespace "$NS" 1>/dev/null
  installed "Mongodb RBAC has been deployed successfully!"
}

deployOperator() {
  deploying "Installing Mongodb Operator"
  kubectl apply -k ./$operator/config/manager --namespace "$NS" 1>/dev/null
  installed "Mongodb Operator has been installed successfully!"
}

deployReplicaSet() {
  deploying "Deploying Mongodb replica set"
  kubectl apply -k . --namespace "$NS" 1>/dev/null
  installed "Mongodb replica set has been deployed successfully!"
}

# Function to run a command with error handling
run_command() {
  # shellcheck disable=SC2124
  local command=$@
  local output
#  LOG_DEBUG "Running command: $command"
  # Execute the command passed to the function
  output=$($command)
  local status=$?

  # Check the exit status of the command
  if [ $status -ne 0 ]; then
    echo "Error: Command failed with status $status"
    exit $status
  fi

  LOG_SUCCESS "$output"
}


deployOperatorUsingHelm() {
  deploying "Installing MongoDB Operator"
  kubectl create ns "$NS" &> /dev/null
  helm repo add mongodb https://mongodb.github.io/helm-charts &> /dev/null
  helm repo update &> /dev/null
  helm install community-operator mongodb/community-operator -f operator-values.yml --namespace "$NS" &> /dev/null
  installed "Mongodb Operator has been installed successfully!"
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
