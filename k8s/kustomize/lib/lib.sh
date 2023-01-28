#!/bin/bash

declare color_green
color_green=$(tput setaf 2)
declare color_reset
color_reset=$(tput sgr0)

# bashsupport disable=BP3001
LOG() {
  local red='\033[0;31m'
  local green='\033[0;32m'
  local yellow='\033[0;33m'
  local blue='\033[0;34m'
  local magenta='\033[0;35m'
  local cyan='\033[0;36m'
  local clear='\033[0m'
  local NOCOLOR='\033[0m'
  local RED='\033[0;31m'
  local GREEN='\033[0;32m'
  local ORANGE='\033[0;33m'
  local BLUE='\033[0;34m'
  local PURPLE='\033[0;35m'
  local CYAN='\033[0;36m'
  local LIGHTGRAY='\033[0;37m'
  local DARKGRAY='\033[1;30m'
  local LIGHTRED='\033[1;31m'
  local LIGHTGREEN='\033[1;32m'
  local YELLOW='\033[1;33m'
  local LIGHTBLUE='\033[1;34m'
  local LIGHTPURPLE='\033[1;35m'
  local LIGHTCYAN='\033[1;36m'
  local WHITE='\033[1;37m'

  local icon_INFO="🔵"
  local icon_DEBUG="🟣"
  local icon_WAIT="🟣"
  local icon_WARN="🟠"
  local icon_ERROR="🔴"
  local icon_SUCCESS="🟢"
  local dt level msg
  local color_date color_ERROR color_ERROR_bold color_INFO color_SUCCESS color_SUCCESS_bold
  local color_WARN color_WARN_bold color_INFO_bold color_DEBUG color_WAIT color_DEBUG_bold color_WAIT_bold color_text
  color_date=$(tput setaf 6)
  color_ERROR=$(tput setaf 1)
  color_ERROR_bold=$(tput setaf 9)
  color_SUCCESS=$color_green
  color_SUCCESS_bold=$(tput setaf 10)
  color_WARN=$(tput setaf 3)
  color_WARN_bold=$(tput setaf 11)
  color_INFO=$(tput setaf 4)
  color_INFO_bold=$(tput setaf 12)
  color_DEBUG=$(tput setaf 5)
  color_DEBUG_bold=$(tput setaf 13)
  color_WAIT=$(tput setaf 5)
  color_WAIT_bold=$(tput setaf 13)
  color_text=$(tput setaf 15)
  level="$1"
  local level_color="color_$level"
  msg="$2"
  if [ "$level" == "ERROR" ]; then
    msg="$color_ERROR_bold$msg$color_reset"
  else
    if [ "$level" == "WAIT" ]; then
      msg="$color_WAIT_bold$msg$color_reset"
    else
      if [ "$level" == "SUCCESS" ]; then
        msg="$color_SUCCESS_bold$msg$color_reset"
      else
        if [ "$level" == "WARN" ]; then
          msg="$color_WARN$msg$color_reset"
        else
          msg="$color_text$msg$color_reset"
        fi
      fi
    fi
  fi
  dt=$(date '+%Y-%m-%d %T')
  local icon="icon_$level"

  printf "%s %s - %20s - %s\n" "${!icon}" "$color_date$dt$color_reset" "[${!level_color}$level$color_reset]" "$msg"
}

LOG_INFO() {
  LOG "INFO" "$1"
}

LOG_DEBUG() {
  LOG "DEBUG" "$1"
}

LOG_WAIT() {
  LOG "WAIT" "$1"
}

LOG_WARN() {
  LOG "WARN" "$1"
}

LOG_ERROR() {
  LOG "ERROR" "$1"
}

LOG_SUCCESS() {
  LOG "SUCCESS" "$1"
}

deploying() {
#  printf "\t⚙️  %s..." "$1"
  LOG_INFO "⚙️  $1..."
}

installed() {
  LOG_SUCCESS "✅ $1"
}

ready() {
#  printf "🚀 %s\n" "$1"
  LOG_SUCCESS "🚀 $1"
}

checking() {
#  printf "⁉️  %s...\n" "$1"
  LOG_WARN "⁉️ $1..."
}

progress() {
#  printf "\t⁉️❔ %s..." "$1"
  LOG_DEBUG "⁉️❔ $1..."
  #  printf "️❔ %s..." "$1"
  #  printf "️⁉️ %s..." "$1"
}

log() {
  LOG_DEBUG "📣 $1..."
}

info() {
#  printf "📣🔵  %s\n" "$1"
  LOG_INFO "$1"
}

success() {
#  printf "📣🟢  %s" "$1"
  LOG_SUCCESS "$1"
}

prompt() {
#  printf "\t‼️🟠️  %s\n" "$1"
  LOG_WARN "$1"
}

verify() {
  declare NS="$1"
  declare pod="$2"
  declare status
  declare timeout=3
  declare service="$3"
  # bashsupport disable=BP3001
  declare spin='-\/'
  declare i=0
  progress "Checking '$pod' status in '$NS' namespace for '$service'"

  status=$(kubectl get po -n "$NS" 2>/dev/null | grep "$pod" | awk '{print $3}' 2>/dev/null)

  #  progress "Checking $pod status"
  while [[ "$status" != "Running" ]]; do
    status=$(kubectl get po -n "$NS" 2>/dev/null | grep "$pod" | awk '{print $3}' 2>/dev/null)

    i=$(((i + 1) % 4))
    #    echo -ne "\b${spin:$i:1}"
    LOG_WAIT "Waiting for '$pod' pod in '$NS' namespace"
    if [[ "$status" != "Running" ]]; then
      sleep $timeout
    fi
  done
  installed "$pod is successfully $status in namespace: $NS"

  #  echo ""
  ready "$service is up and running"
}

waitForInput() {
  prompt "$1"
  prompt "*** Once you have done the step, pres ENTER"
  read -r
#  echo ""
}

setKeycloakIngress() {
  local exp="s/KEYCLOAK_INGRESS/$1/g"
  sed -e "$exp" keycloak/base/kustomization-org.yaml > keycloak/base/kustomization.yaml
}
