#!/bin/bash

setupMongoDB() {
  cd mongodb || exit
  ./run.sh "webhookie-mongodb"
  cd ..
}
