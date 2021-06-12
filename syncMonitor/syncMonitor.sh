#!/bin/bash
#
#  algodMon - syncMonitor - v1.0 - Node Synchronization Monitor
# 
#  Donations: OBQIVIPTUXZENH2YH3C63RHOGS7SUGGQTNJ52JR6YFHEVFK5BR7BEYKQKI
#

# Set ALGORAND_DATA and nodePath
sourceDir=$(dirname "$0");
brk=$(printf '=%.0s' {1..60}); brks=$(printf '=%.0s' {1..30});
echo -e "\n\n${brk}\nalgodMon - syncMonitor - Node Synchronization Monitor\n${brk}";
if [[ ! -f ${sourceDir}/monitorConfig.cfg ]]; then
	echo -e "\n\n${brks}\nConfiguration - Algorand Data\n${brks}";
	echo -e "\nPlease specify the path to the ALGORAND_DATA directory...\n\nExample: $HOME/node/data\n\n"; read ALGORAND_DATA;
	echo -e "\n\nYou have entered: ${ALGORAND_DATA}\n"
	echo -e "\n${brks}\nSaving Config\n${brks}\n\nWriting config: ${sourceDir}/monitorSync.cfg";
	echo "ALGORAND_DATA=${ALGORAND_DATA}" > ${sourceDir}/monitorConfig.cfg; echo -e "\nDone.\n";
else
source ${sourceDir}/monitorConfig.cfg;
fi;
nodePath=$(echo ${ALGORAND_DATA} | sed 's/\/node\/data/\/node/g');
echo -e "\n${brks}\nCurrent Config\n${brks}\n\n\tALGORAND_DATA=${ALGORAND_DATA}\n\tnodePath=${nodePath}"

# Goal - Get Status
echo -e "\n\n${brk}\nNode Synchronization Check\n${brk}";
echo -e "\nProcessing:  Loaded Config\n\tALGORAND_DATA=${ALGORAND_DATA}\n\tnodePath=${nodePath}\n\tsourceDir=${sourceDir}"
echo -e "\nProcessing:  ${nodePath}/goal node status\n\n"
${nodePath}/goal node status 2> ${sourceDir}/lastStatus.err > ${sourceDir}/lastStatus;
cat ${sourceDir}/lastStatus;

# Goal - Error handling
errorCheck=$(echo $?)
if [[ ${errorCheck} -gt 0 ]]; then 
	echo -e "\nError:  Execution failed\nExit status:  $?";
	echo -e "\n\n${brks}\nNext Step\n${brks}\nPlease retry manual execution of the command:  ${nodePath}/goal node status\n\nCheck log files:"
	echo -e "\t${sourceDir}/lastStatus.err\n\t${sourceDir}";
	echo -e "\n${brks}\n"; cat ${sourceDir}/lastStatus.err; cat ${sourceDir}/lastStatus; echo ""
	kill -9 $BASHPID
fi

# Sync Report - Write function
currentTime=$(echo -e "$(date +%Y-%m-%d)  $(date +%H:%M:%S)");
lastBlock=$(grep "Last committed block:" ${sourceDir}/lastStatus);
diskMonitor=$(du ${ALGORAND_DATA} --summarize | awk '{print $1}');
syncMonitor=$(grep "Catchpoint accounts processed:\|Catchpoint downloaded blocks:\|Catchpoint accounts verified:\|Round for next consensus protocol:" ${sourceDir}/lastStatus | tail -n 1);
syncTime=$(grep "Sync Time:" ${sourceDir}/lastStatus)
echo -e "${currentTime} \t ${diskMonitor} \t ${lastBlock} \t ${syncMonitor} \t ${syncTime}" >> ${sourceDir}/monitorSync.log;

# Sync Report - Monitor function
echo -e "\n\n${brk}\nNode Synchronization Report\n${brk}\n";
echo -e "Date \t    Time \t Last Block \t Node Status";
head -n 1 ${sourceDir}/monitorSync.log;
tail -n 17 ${sourceDir}/monitorSync.log;

# Node Health - Error Check
echo -e "\n\n${brk}\nNode Error Check\n${brk}";
echo -e "\nDo you want to check 'node.log' for errors? (y/n)\n\n"; read errorCheck
if [[ ${errorCheck} = "y" ]]; then 
currentEpoch=$(date +%s);
lastEpoch=$(ls -1tr ${sourceDir}/nodeErrors.log-* 2> /dev/null | tail -n 1);
grep -a "err\|warn" ${ALGORAND_DATA}/node.log > ${sourceDir}/nodeErrors.log;
errorCount=$(wc -l ${sourceDir}/nodeErrors.log | awk '{print $1}');
mv ${sourceDir}/nodeErrors.log ${sourceDir}/nodeErrors.log-${currentEpoch};
if [[ ${errorCount} -gt 0 ]]; then
	echo -e "\n\nWARNING: Errors detected in algod log:  ${ALGORAND_DATA}/node.log\n\nPlease provide error log for review: ${sourceDir}/nodeErrors.log-${currentEpoch}\n\n"
	tail ${sourceDir}/nodeErrors.log-${currentEpoch}
else
	echo -e "\n\nNo errors found in algod log:  ${ALGORAND_DATA}/node.log" 
fi;

ls -l ${lastEpoch} > /dev/null 2>&1
epochStatus=$(echo $?)

if [[ ${epochStatus} == 0 ]]; then
diff ${lastEpoch} ${sourceDir}/nodeErrors.log-${currentEpoch} >/dev/null 2>&1
diffStatus=$(echo $?)
if [[ ${diffStatus} == 0 ]]; then
rm -f ${lastEpoch};
echo -e "\nError File:  ${sourceDir}/nodeErrors.log-${currentEpoch}"
fi; fi; fi;
