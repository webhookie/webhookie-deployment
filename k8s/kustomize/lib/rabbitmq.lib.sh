#!/bin/bash

setupRabbitMQ() {
  cd rabbitmq || exit
  ./run.sh "webhookie-rabbitmq"
  cd ..
}
