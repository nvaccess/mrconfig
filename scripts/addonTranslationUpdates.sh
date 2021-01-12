#!/usr/bin/env bash

AddonName="${1}"
PathToAddons=/home/nvdal10n/mr/addons
LogDir=/home/nvdal10n/translationUpdateLogs

_doAddonTranslationUpdate(){
  set -x # for echo of commands and variables
  addonPath=$1
  cd "${addonPath}"
  if [ $? -ne 0 ] ; then
    echo Return early
    set +x
    return 1
  fi
  mr addon2svn
  if [ $? -ne 0 ] ; then
    echo Return early
    set +x
    return 1
  fi
  mr svn2addon
  if [ $? -ne 0 ] ; then
    echo Return early
    set +x
    return 1
  fi
  set +x
  return 0
}

logPath="${LogDir}/addon-${AddonName}.log"
_doAddonTranslationUpdate "${PathToAddons}/${AddonName}" &>"${logPath}"
if [ $? -ne 0 ] ; then
  echo Failure during addon translation update: ${AddonName}
  cat "${logPath}";
fi
