#!/bin/bash

setupMonitoring() {
  cd monitoring || exit
  ./run.sh "webhookie-monitoring"
  cd ..
}
