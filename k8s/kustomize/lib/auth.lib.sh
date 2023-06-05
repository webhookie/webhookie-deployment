#!/bin/bash
# shellcheck disable=SC2154

initIAM() {
  LOG_INFO "Using ${color_green}Auth0${color_reset}"
}

updateForIAM() {
  LOG_INFO "Copying ${color_green}$authFile${color_reset} to data/auth.env"
  cp "$authFile" data/auth.env
}

waitForIAM() {
  if ! $isMinikube; then
    waitForInput "Add $url to your Allowed Callback URLs in you Identity Provider"
  fi
}
