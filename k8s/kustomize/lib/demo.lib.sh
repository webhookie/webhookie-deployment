#!/bin/bash

setupDemo() {
  local NS="webhookie-demo"
  kubectl create ns "$NS" &> /dev/null
  LOG_INFO "Deploying webhookie sample subscription...."
  kubectl apply -k ./subscription-sample -n "$NS" &>/dev/null
  installed "webhookie sample subscription has been deployed successfully!"
}
