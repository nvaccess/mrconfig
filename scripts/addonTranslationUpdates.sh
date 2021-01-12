#!/usr/bin/env bash

AddonName="${1}"
PathToAddons=/home/nvdal10n/mr/addons
LogDir=/home/nvdal10n/translationUpdateLogs/

_doAddonTranslationUpdate(){
  set -x # for echo of commands and variables
  addonPath="${PathToAddons}/$1"

  if cd "${addonPath}"; then
    echo Exit early
    set +x
    return 1
  fi
  if mr addon2svn; then
    echo Exit early
    set +x
    return 1
  fi
  if mr svn2addon; then
    echo Exit early
    set +x
    return 1
  fi
}

logPath="${LogDir}/addon-${AddonName}.log"
if _doAddonTranslationUpdate "${PathToAddons}/${AddonName}" &>"${logPath}"; then
  cat "${logPath}";
fi
