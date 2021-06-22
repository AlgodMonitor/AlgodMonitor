#!/bin/bash
#
#  algodMon v1.1 - storageMonitor - Storage Utilization Monitor 
# 
#  Donate/Register: OBQIVIPTUXZENH2YH3C63RHOGS7SUGGQTNJ52JR6YFHEVFK5BR7BEYKQKI
#
#  Copyright 2021 - Consiglieri-cfi
#

# Initialization
globalSettings=$(dirname "$0")/../config/globalSettings.cfg;
if [ ! -f ${globalSettings} ]; then
echo -e "\n\nERROR: Missing configuration file!\n\nExpected Path: ${globalSettings}\n\n";
kill ${BASHPID}; else source ${globalSettings}; fi;

# Banner
echo -e "\n\n${brk}\nalgodMon - storageMonitor - Storage Utilization Monitor - Initialization\n${brk}";

# Configuration - Set Data Director
storageConfig=${configDir}/dataDir.cfg
if [ ! -f ${storageConfig} ]; then
echo -e "\n\nPlease enter path to the data directory...\n\nExample: ${HOME}/node/data/mainnet-v1.0\n\nNote: Do not include '~' in path."
read dataDir;
echo -e "dataDir=${dataDir}" > ${storageConfig}
else
source ${storageConfig};
echo -e "\n\nLoaded configuration: ${storageConfig}\n\nData Directory: ${dataDir}\n";
fi;

# Execution Tracker
echo -e "\n\nLast Executed: $(date -r ${logDir}/monitorStorage.log +"%Y-%m-%d %H:%M:%S" 2</dev/null)\nCurrent Time:  ${currentDate} ${currentSecond}\n"

# Count - Update
storageLog=${logDir}/monitorStorage.log;
diskUtilization=$(du -xL ${dataDir}/../ --max-depth=0 | awk '{print $1}');
sizeBlock=$(ls -l ${dataDir}/ledger.block.sqlite | awk '{print $5}');
sizeBlockSHM=$(ls -l ${dataDir}/ledger.block.sqlite-shm | awk '{print $5}');
sizeBlockWAL=$(ls -l ${dataDir}/ledger.block.sqlite-wal | awk '{print $5}');
sizeTracker=$(ls -l ${dataDir}/ledger.tracker.sqlite | awk '{print $5}');
sizeTrackerSHM=$(ls -l ${dataDir}/ledger.tracker.sqlite-shm | awk '{print $5}');
sizeTrackerWAL=$(ls -l ${dataDir}/ledger.tracker.sqlite-wal | awk '{print $5}');
sizeNodeLog=$(du -xL ${dataDir}/../node.log | awk '{print $1}');
sizeErrLogs=$(du ${dataDir}/../algod-err* | awk '{sum+=$1}END{print sum}');

# Count - Write
echo -e "${currentTime} ${diskUtilization} ${sizeBlock} ${sizeBlockSHM} ${sizeBlockWAL} ${sizeTracker} ${sizeTrackerSHM} ${sizeTrackerWAL} ${sizeNodeLog} ${sizeErrLogs}" >> ${storageLog};

# Count - Report
echo -e "\n\n${brk}\nalgodMon - storageMonitor - Storage Utilization Monitor - Report\n${brk}\n";
echo -e "Date Time Utilized block.db b-shm b-wal tracker.db t-shm t-wal node.log algod-err\n$(head -n 1 ${storageLog})\n$(tail -n 20 ${storageLog})" | column -t;
