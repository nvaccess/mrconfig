#!/usr/bin/env bash
PathToMrRepo=/home/nvdal10n/mr/
LogDir=/home/nvdal10n/translationUpdateLogs/

_doNVDATranslationUpdate(){
  error=0
  set -x # for echo of commands and variables
  logPath="${LogDir}/mr-up.log"
  cd $PathToMrRepo && mr up &> $logPath;
  if [ $? -ne 0 ]; then
    echo mr up failed
    error=1
  fi

  logPath="${LogDir}/mr-svn2nvda.log"
  cd ${PathToMrRepo}/srt/ && mr svn2nvda &> $logPath
  if [ $? -ne 0 ]; then
    echo mr svn2nvda failed
    error=1
  fi

  logPath="${LogDir}/mr-mergePot.log"
  cd ${PathToMrRepo}/srt/ && mr mergePot &> $logPath
  if [ $? -ne 0 ]; then
    echo mr mergePot failed
    error=1
  fi

  logPath="${LogDir}/mr-findRevs.log"
  cd ${PathToMrRepo}/srt/ && mr findRevs &> $logPath
  if [ $? -ne 0 ]; then
    echo mr findRevs failed
    error=1
  fi

  return $error
}

logPath="${LogDir}/nvdaTranslationUpdates.log"
if _doNVDATranslationUpdate &>"${logPath}"; then
  cat "${logPath}";
fi

