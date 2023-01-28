#!/bin/bash

setupDemo() {
  local NS="webhookie-demo"
  kubectl create ns "$NS" &> /dev/null
  info "Deploying webhookie sample subscription...."
  kustomize build ./subscription-sample | kubectl apply -n "$NS" -f - &>/dev/null
  finished
}
