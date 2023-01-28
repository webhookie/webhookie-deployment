#!/bin/bash
# shellcheck disable=SC2034
. ./lib/lib.sh

declare arch="amd"
# shellcheck disable=SC2034
declare auth_provider="keycloak"
declare isKeycloak=true
declare authFile=""
declare isArm=false
declare runSample="false"
declare monitoring="false"
declare logging="false"
declare kube_context=""
declare isEKS=false
declare isMinikube=false
declare protocol_scheme="http"
declare host="localhost"
declare url
url="$protocol_scheme://$host"

. ./lib/keycloak.lib.sh
. ./lib/mongodb.lib.sh
. ./lib/rabbitmq.lib.sh
. ./lib/monitoring.lib.sh
. ./lib/logging.lib.sh
. ./lib/demo.lib.sh
. ./lib/webhookie.lib.sh

. ./lib/init.lib.sh
. ./lib/env.lib.sh

setup() {
  initCluster

  setupMongoDB
  setupRabbitMQ

  if [[ $monitoring == "true" ]]; then
    setupMonitoring
  fi

  if [[ $logging == "true" ]]; then
    setupLogging
  fi

  initIAM

  setupWebhookie

  if [[ $runSample == "true" ]]; then
    setupDemo
  fi
}

run() {
  waitForCluster
  waitForGateway
  waitForIAM

  ready "Opening $url..."
  start "$url" 2> /dev/null
  xdg-open "$url" 2> /dev/null
  open "$url" 2> /dev/null
}

cleanup() {
  success "Cleaning up..."
  rm -rf services/data/auth.env
  rm -rf keycloak/base/realm.json
  rm -rf keycloak/base/kustomization.yaml
  finished
}

setup
run
cleanup
