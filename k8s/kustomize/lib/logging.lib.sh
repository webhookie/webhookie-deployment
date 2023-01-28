#!/bin/bash

setupLogging() {
  cd logging || exit
  ./run.sh "webhookie-logging" --deploy
  cd ..
}
