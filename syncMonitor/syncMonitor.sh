#!/bin/bash
#
#  algodMon - v1.1 - syncMonitor - Node Synchronization Monitor
#
#  Donations: OBQIVIPTUXZENH2YH3C63RHOGS7SUGGQTNJ52JR6YFHEVFK5BR7BEYKQKI
#
#  Copyright 2021 - Consiglieri-cfi
#

# Initialization
sourceDir=$(dirname "$0");
logDir=${sourceDir}/../logs;
configDir=${sourceDir}/../config;
currentDate=$(date +%Y-%m-%d);
currentSecond=$(date +%H:%M:%S);
currentEpoch=$(date +%s);
currentTime=$(echo -e "${currentDate} ${currentSecond}");
brk=$(printf '=%.0s' {1..120}); brkm=$(printf '=%.0s' {1..70}); brks=$(printf '=%.0s' {1..30});
echo -e "\n\n${brk}\nalgodMon - syncMonitor - Node Synchronization Monitor\n${brk}";

# Configuration - Data Directory
if [[ ! -f ${configDir}/monitorConfig.cfg ]]; then
	echo -e "\n\n${brks}\nConfiguration - Algorand Data\n${brks}";
	echo -e "\nPlease specify the path to the ALGORAND_DATA directory...\n\nExample: $HOME/node/data\n\n"; read ALGORAND_DATA;
	echo -e "\n\nYou have entered: ${ALGORAND_DATA}\n"
	echo -e "\n${brks}\nSaving Config\n${brks}\n\nWriting config: ${sourceDir}/monitorSync.cfg";
	echo "ALGORAND_DATA=${ALGORAND_DATA}" > ${configDir}/monitorConfig.cfg; echo -e "\nDone.\n";
else
source ${configDir}/monitorConfig.cfg;
fi;

# Configuration - Report
export ALGORAND_DATA=${ALGORAND_DATA};
nodePath=$(echo ${ALGORAND_DATA} | sed 's/\/node\/data/\/node/g');
echo -e "\n${brks}\nCurrent Config\n${brks}\n\n\tALGORAND_DATA=${ALGORAND_DATA}\n\tnodePath=${nodePath}\n\tsourceDir=${sourceDir}"

# Goal - Check Status
sourceDir=$(dirname "$0");
echo -e "\n\n${brk}\nNode Synchronization Check\n${brk}";
echo -e "\nProcessing:  ${nodePath}/goal node status\n"
${nodePath}/goal node status 2> ${sourceDir}/lastStatus.err > ${sourceDir}/lastStatus;

# Goal - Error handling
errorCheck=$(echo $?)
if [[ ${errorCheck} -gt 0 ]]; then 
        echo -e "\nError:  Execution failed\nExit status:  $?";
        echo -e "\n\n${brks}\nNext Step\n${brks}\nPlease retry manual execution of the command:\n\t${nodePath}/goal node status\n\nCheck log files:"
        echo -e "\t${sourceDir}/lastStatus\n\t${nodePath}/lastStatus.err\n\t${ALGORAND_DATA}/node.log\n\n";
        kill -9 $BASHPID
fi;
echo -e "\nDone.\n"

# Synchronization - Check Status
diskMonitor=$(du ${ALGORAND_DATA} --summarize | awk '{print $1}');
syncMonitor=$(grep "Catchpoint accounts processed:\|Catchpoint downloaded blocks:\|Catchpoint accounts verified:\|Round for next consensus protocol:" ${sourceDir}/lastStatus | tail -n 1 | awk '{print $NF}');
lastBlock=$(grep "Last committed block:" ${sourceDir}/lastStatus | awk '{print $NF}');
syncTime=$(grep "Sync Time:" ${sourceDir}/lastStatus | awk '{print $NF}')
echo -e "${currentTime} ${diskMonitor} ${lastBlock} ${syncMonitor} ${syncTime}" >> ${logDir}/monitorSync.log;

# Synchronization - Report
echo -e "\n${brk}\nNode Synchronization Report\n${brk}\n";
echo -e "Date Time Disk_Util Last_Block Round Sync\n$(head -n 1 ${logDir}/monitorSync.log)\n$(tail -n 17 ${logDir}/monitorSync.log)" | column -t
