#!/bin/bash
# shellcheck disable=SC2154

initIAM() {
  LOG_INFO "Using ${color_green}Auth0${color_reset}"
}

updateForIAM() {
  cp "$authFile" data/auth.env
}

waitForIAM() {
  if ! $isMinikube; then
    waitForInput "Add $url to your Allowed Callback URLs in you Identity Provider"
  fi
}
