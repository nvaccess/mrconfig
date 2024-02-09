#!/usr/bin/env bash
PathToMrRepo=/home/nvdal10n/mr
LogDir=/home/nvdal10n/translationUpdateLogs

_doNVDATranslationUpdate(){
  error=0
  set -x # for echo of commands and variables
  upLogPath="${LogDir}/mr-up.log"
  cd $PathToMrRepo && mr up &> $upLogPath;
  if [ $? -ne 0 ] ; then
    echo mr up failed
    error=1
  fi

  svn2nvdaLogPath="${LogDir}/mr-svn2nvda.log"
  cd ${PathToMrRepo}/srt/ && mr svn2nvda &> $svn2nvdaLogPath
  if [ $? -ne 0 ] ; then
    echo mr svn2nvda failed
    error=1
  fi

  findRevsLogPath="${LogDir}/mr-findRevs.log"
  cd ${PathToMrRepo}/srt/ && mr findRevs &> $findRevsLogPath
  if [ $? -ne 0 ] ; then
    echo mr findRevs failed
    error=1
  fi

  set +x
  return $error
}

logPath="${LogDir}/nvdaTranslationUpdates.log"
_doNVDATranslationUpdate &>"${logPath}"
if [ $? -ne 0 ] ; then
  echo Failure during NVDA translation update:
  cat "${logPath}";
fi

