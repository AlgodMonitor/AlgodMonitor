#!/bin/bash
#
#  algodMon v1.2 - storageMonitor - Storage Utilization Monitor 
#
#  Copyright 2021 - Consiglieri-cfi
#

# Initialization
globalValues=$(dirname "$0")/../config/globalValues.cfg;
if [ ! -f ${globalValues} ]; then
echo -e "\n\nERROR: Missing configuration file!\n\nExpected Path: ${globalValues}\n\n";
kill ${BASHPID}; else source ${globalValues}; fi;

# Banner
echo -e "\n\n${brk}\nalgodMon - storageMonitor - Storage Utilization Monitor - Initialization\n${brk}";

# Execution Tracker
echo -e "\n\nLast Executed: $(date -r ${logDir}/monitorStorage.log +"%Y-%m-%d %H:%M:%S" 2</dev/null)\nCurrent Time:  ${currentDate} ${currentSecond}\n"

# Count - Update
networkDir=${dataDir}/*net*;
storageLog=${logDir}/monitorStorage.log;
diskUtilization=$(du -xL ${networkDir}/../ --max-depth=0 | awk '{print $1}');
sizeBlock=$(ls -l ${networkDir}/ledger.block.sqlite | awk '{print $5}');
sizeBlockSHM=$(ls -l ${networkDir}/ledger.block.sqlite-shm | awk '{print $5}');
sizeBlockWAL=$(ls -l ${networkDir}/ledger.block.sqlite-wal | awk '{print $5}');
sizeTracker=$(ls -l ${networkDir}/ledger.tracker.sqlite | awk '{print $5}');
sizeTrackerSHM=$(ls -l ${networkDir}/ledger.tracker.sqlite-shm | awk '{print $5}');
sizeTrackerWAL=$(ls -l ${networkDir}/ledger.tracker.sqlite-wal | awk '{print $5}');
sizeNodeLog=$(du -xL ${networkDir}/../node.log | awk '{print $1}');
sizeErrLogs=$(du ${networkDir}/../algod-err* | awk '{sum+=$1}END{print sum}');

# Count - Write
echo -e "${currentTime} ${diskUtilization} ${sizeBlock} ${sizeBlockSHM} ${sizeBlockWAL} ${sizeTracker} ${sizeTrackerSHM} ${sizeTrackerWAL} ${sizeNodeLog} ${sizeErrLogs}" >> ${storageLog};

# Count - Report
echo -e "\n\n${brk}\nalgodMon - storageMonitor - Storage Utilization Monitor - Report\n${brk}\n";
echo -e "Date Time Utilized block.db b-shm b-wal tracker.db t-shm t-wal node.log algod-err\n$(head -n 1 ${storageLog})\n$(tail -n 20 ${storageLog})" | column -t;
