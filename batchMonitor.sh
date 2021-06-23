#!/bin/bash
#
#  algodMon v1.2 - batchMonitor - Monitor Scheduling Agent
#
#  Copyright 2021 - Consiglieri-cfi
#

sourceDir=$(dirname "$0");
${sourceDir}/networkMonitor/networkMonitor.sh
${sourceDir}/partkeyMonitor/partkeyMonitor.sh
${sourceDir}/storageMonitor/storageMonitor.sh
${sourceDir}/tokenMonitor/tokenMonitor.sh
${sourceDir}/syncMonitor/syncMonitor.sh
${sourceDir}/voteMonitor/voteMonitor.sh
