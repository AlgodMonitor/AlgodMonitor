#!/bin/bash
#
#  Algod Monitor - v1.3 - View Logs - Log Report Viewer
#
#  Copyright 2022 - Algod Monitor
#

# Initialization
sourceDir=$(dirname "$0");
logDir=${sourceDir}/logs;
configDir=${sourceDir}/config;
brk=$(printf '=%.0s' {1..120});
brkm=$(printf '=%.0s' {1..70});
brks=$(printf '=%.0s' {1..30});

# Component Variables
for viewComponent in viewAll viewErrors viewNetwork viewPartKey viewTokens viewVotes viewStorage viewSync; do export ${viewComponent}=0; done
componentName=$1

# Component Selector
if [ "${componentName}" = "all" ]; then
viewAll=1;
elif [ "${componentName}" = "errors" ]; then
viewErrors=1;
elif [ "${componentName}" = "network" ]; then
viewNetwork=1;
elif [ "${componentName}" = "partkey" ]; then
viewPartKey=1;
elif [ "${componentName}" = "tokens" ]; then
viewTokens=1;
elif [ "${componentName}" = "votes" ]; then
viewVotes=1;
elif [ "${componentName}" = "storage" ]; then
viewStorage=1;
elif [ "${componentName}" = "sync" ]; then
viewSync=1;
elif [ "${componentName}" = "perf" ]; then
viewPerf=1;
else
echo -e "\n\n${brk}\nalgodMon - viewLogs - Log Report Viewer\n${brk}\n";
echo -e "\nDisplay 'algodMonitor' reports and file information on screen.\n\nPlease specify a component when running the 'viewLogs' command.\n";
echo -e "\nExample:\n\t ./viewLogs.sh all \n\t ./viewLogs.sh errors \n\t ./viewLogs.sh partkey \n";
echo -e "\nOptions:\n\t all \n\t errors \n\t network \n\t partkey \n\t tokens \n\t votes \n\t storage \n\t sync \n\t perf\n\n";
echo -e "\nEnter a component name...\n\n"; read componentName;
echo -e "\n\n\nDisplaying ${componentName} report...\n";
${sourceDir}/view-logs.sh ${componentName};
fi;

# Redirect - Config
if [ "${viewPerf}" = "1" ]; then
echo -e "\nExecuting: ${sourceDir}/perf-monitor/perf-monitor.sh\n";
${sourceDir}/perf-monitor/perf-monitor.sh;
fi;

# View All
if [ ${viewAll} == "1" ]; then
viewErrors=1;
viewNetwork=1;
viewPartKey=1;
viewTokens=1;
viewVotes=1;
viewStorage=1;
viewSync=1;
echo
fi;

# View Errors
if [ ${viewErrors} == "1" ]; then
echo -e "\n\n${brk}\nAlgod Monitor - Error Monitor - Node Error Report\n${brk}\n";
echo -e "Date Time Error Warning Err_Total Warn_Total Truncate SizeNew SizeOld FS_Type\n$(timeout 10 tail -n 20 ${logDir}/monitorErrors.log)" | column -t;
fi;

# View Network
if [ ${viewNetwork} == "1" ]; then
echo -e "\n\n${brk}\nAlgod Monitor - Network Monitor - Network Peers Report\n${brk}\n";
firstReport=$(ls -1t ${logDir}/networkPeers/* | tail -n1)
lastReport=$(ls -1tr ${logDir}/networkPeers/monitorPeers-* | tail -n1);
tail -n 30 ${lastReport};
echo -e "\n\nFirst Report: $(date -r ${firstReport} +"%Y-%m-%d %H:%M:%S")"
echo -e "Last Report: $(date -r ${lastReport} +"%Y-%m-%d %H:%M:%S")"

echo -e "\n\nTotal Peers: $(wc -l ${lastReport} | awk '{print $1}')"
echo -e "Total Records: $(awk '{sum+=$1}END{print sum}' ${lastReport})\n\n"
fi;

# View Part Key
if [ ${viewPartKey} == "1" ]; then
echo -e "\n\n${brk}\nAlgod Monitor - Part Ley Monitor - Participation Key Expiration Report\n${brk}\n";
echo -e "Date Time Current End RoundsLeft DaysLeft Expiration Registered\n$(timeout 10 tail -n 20 ${logDir}/monitorExpiration.log)" | column -t
fi;

# View Tokens
if [ ${viewTokens} == "1" ]; then
echo -e "\n\n${brk}\nAlgod Monitor - Token Monitor - Account Balance Report\n${brk}\n";
echo -e "Report coming soon...";
fi;

# View Votes
if [ ${viewVotes} == "1" ]; then
echo -e "\n\n${brk}\nAlgod Monitor - Vote Monitor - Consensus Vote Report\n${brk}\n";
echo -e "Date Time Previous New Today Total\n$(timeout 10 tail -n 20 ${logDir}/monitorVotes.log)" | column -t
fi;

# View Storage
if [ ${viewStorage} == "1" ]; then
echo -e "\n\n${brk}\nAlgod Monitor - Storage Monitor - Storage Utilization Report\n${brk}\n";
echo -e "Date Time Utilized block.db b-shm b-wal tracker.db t-shm t-wal node.log algod-err\n$(timeout 10 tail -n 20 ${logDir}/monitorStorage.log)" | column -t;
fi;

# View Sync
if [ ${viewSync} == "1" ]; then
echo -e "\n\n${brk}\nAlgod Monitor - Sync Monitor - Node Synchronization Report\n${brk}\n";
echo -e "Date Time Disk_Util Last_Block Round Sync\n$(timeout 10 tail -n 20 ${logDir}/monitorSync.log)" | column -t
fi;
