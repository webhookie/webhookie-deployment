#!/bin/bash

setupWebhookie() {
  verify "webhookie-mongodb" "webhookie-mongodb-0" "MongoDB"
  verify "webhookie-rabbitmq" "webhookie-rabbitmq-server-0" "RabbitMQ"
  declare NS="webhookie-services"
  cd services || exit
  updateForIAM
  ./run.sh "$NS"
  verify "$NS" "api-gateway" "Webhookie Services"
  verify "$NS" "portal" "Webhookie"
  cd ..
}

waitForGateway() {
  # bashsupport disable=BP3001
  local spin='-\|/'
  local i=0

  declare health_endpoint="$url/api/manage/health"
  local message="Waiting fro $url"
  progress "$message"
  until curl --output /dev/null --silent --head --fail "$health_endpoint"; do
    i=$(( (i+1) %4 ))
#    echo -ne  "\b${spin:$i:1}"
    LOG_WAIT "$message"
    sleep 5
  done
  finished
}
