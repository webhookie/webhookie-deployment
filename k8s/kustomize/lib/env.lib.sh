#!/bin/bash

LOG_INFO "Checking prerequisites..."
declare notFound="command not found"

verifyCommand() {
  local result="$2"
  local command="$1"
  if grep -q "$notFound" <<<"$result"; then
    LOG_ERROR "$command not found! Please make sure you install '$command' and run again"
    exit 1
  fi
}

usingVersion() {
  local command="$1"
  local version="$2"
  # shellcheck disable=SC2154
  LOG_INFO "Using ${color_text}$command${color_rest} version ${color_green}$version${color_rest}"
}

verifyCommand "jq" "$(jq --version 2>&1 >/dev/null)"
usingVersion "jq" "$(jq --version)"

verifyCommand "kubectl" "$(kubectl version --client -o json | jq . 2>&1 >/dev/null)"
usingVersion "kubectl" "$(kubectl version --client -o json | jq .clientVersion.gitVersion | sed -r 's/["]+//g')"
usingVersion "kustomize" "$(kubectl version --client -o json | jq .kustomizeVersion | sed -r 's/["]+//g')"

verifyCommand "helm" "$(helm version --short 2>&1 >/dev/null)"
usingVersion "helm" "$(helm version --short)"

# shellcheck disable=SC2086
if [ "$isEKS" == "true" ]; then
  verifyCommand "eksctl" "$(eksctl version 2>&1 >/dev/null)"
  usingVersion "eksctl" "$(eksctl version)"
  eksctlVersion=$(eksctl version)
  versionNumber=$(echo "$eksctlVersion" | cut -d'.' -f 2)
  maxSupportedVersion=114
  if [ "$versionNumber" -gt "$maxSupportedVersion" ]; then
    LOG_ERROR "Clusters created with eksctl version > $maxSupportedVersion is not supported"
    LOG_ERROR "Please make sure you install version $maxSupportedVersion"
    exit 1
  fi
fi

#jqVersion=$(jq --version)
#echo "$jqVersion"
#
#ERROR=$(jq1 --version 2>&1 >/dev/null)

#ver=$(jq1 --version)
#echo "$ver"

#if [[ $ERROR = *"$n"* ]]; then
#  echo "it's found"
#fi
#if [[ $ver = *"$n"* ]]; then
#  echo "it's found"
#fi

#if grep -q "$n" <<< "$ERROR"; then
#  echo "It's there"
#  exit 1
#fi
#if grep -q "$n" <<< "$jqVersion"; then
#  echo "It's there"
#fi
#
#echo "done"
