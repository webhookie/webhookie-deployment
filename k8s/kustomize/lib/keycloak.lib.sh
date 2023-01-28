#!/bin/bash

isKeycloak=true
export isKeycloak

# shellcheck disable=SC2154
initIAM() {
  declare NS="webhookie-keycloak"
  cd keycloak || exit
  local exp="s+WEBHOOKIE_HOST+$url+g"
  sed -e "$exp" base/realm-org.json > base/realm.json
  ./run.sh "$NS" "$arch"
  cd ..
}

# shellcheck disable=SC2154
updateForIAM() {
  local auth_url="$url"
  if $isMinikube; then
    auth_url="$url:8800"
  fi
  local exp="s+WEBHOOKIE_HOST+$auth_url+g"
  sed -e "$exp" data/keycloak-org.env > data/auth.env
}

waitForIAM() {
  if ! $isEKS; then
    portForward "webhookie-keycloak" "webhookie-keycloak" 8800 8080
  fi
}
