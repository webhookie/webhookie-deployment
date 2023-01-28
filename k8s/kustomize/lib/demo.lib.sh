#!/bin/bash

setupDemo() {
  local NS="webhookie-demo"
  kubectl create ns "$NS" &> /dev/null
  LOG_INFO "Deploying webhookie sample subscription...."
  kustomize build ./subscription-sample | kubectl apply -n "$NS" -f - &>/dev/null
  installed "webhookie sample subscription has been deployed successfully!"
}
