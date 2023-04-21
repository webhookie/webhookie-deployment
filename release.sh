#!/bin/bash

declare build=${BUILD_NUMBER:=0}
declare version="v1.0.$build"

createZip() {
  local module="$1"
  local folder="$2"
  local prefix="webhookie-$module"
  local output="$prefix-$version"
  mkdir "$output"
  cp -r "$folder"/* ./"$output"
  zip -r "$prefix"-scripts.zip "$output"
  rm -rf "$output"
}

createZip "k8s" "k8s/kustomize"
createZip "docker-compose" "docker"
