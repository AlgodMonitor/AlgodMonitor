#!/bin/bash
#
#  algodMon v1.1 - storageMonitor - Storage Utilization Monitor 
# 
#  Donate/Register: OBQIVIPTUXZENH2YH3C63RHOGS7SUGGQTNJ52JR6YFHEVFK5BR7BEYKQKI
#
#  Copyright 2021 - Consiglieri-cfi
#

# Initialization
sourceDir=$(dirname "$0");
currentDate=$(date +%Y-%m-%d);
currentSecond=$(date +%H:%M:%S);
currentEpoch=$(date +%s);
currentTime=$(echo -e "${currentDate}  ${currentSecond}");
brk=$(printf '=%.0s' {1..120}); brks=$(printf '=%.0s' {1..30});
echo -e "\n\n${brk}\nalgodMon - storageMonitor - Storage Utilization Monitor - Initialization\n${brk}";

# Configuration - Set Data Director
storageConfig=${sourceDir}/dataDir.cfg
if [ ! -f ${storageConfig} ]; then
echo -e "\n\nPlease enter path to the data directory...\n\nExample: ~/node/data/mainnet-v1.0\n\n"
read dataDir;
echo -e "dataDir=${dataDir}" > ${storageConfig}
else
source ${storageConfig};
echo -e "\n\nLoaded configuration: ${storageConfig}\n\nData Directory: ${dataDir}\n";
fi;

# Execution Tracker
echo -e "\n\nLast Executed: $(date -r ${sourceDir}/storage_monitor.log +"%Y-%m-%d %H:%M:%S" 2</dev/null)\nCurrent Time:  ${currentDate} ${currentSecond}\n"

# Count - Update
storageLog=${sourceDir}/storage_monitor.log;
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
