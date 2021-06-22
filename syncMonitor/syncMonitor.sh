#!/bin/bash
#
#  algodMon - v1.2 - syncMonitor - Node Synchronization Monitor
#
#  Donations: OBQIVIPTUXZENH2YH3C63RHOGS7SUGGQTNJ52JR6YFHEVFK5BR7BEYKQKI
#
#  Copyright 2021 - Consiglieri-cfi
#

# Initialization
globalSettings=$(dirname "$0")/../config/globalSettings.cfg;
if [ ! -f ${globalSettings} ]; then
echo -e "\n\nERROR: Missing configuration file!\n\nExpected Path: ${globalSettings}\n\n";
kill ${BASHPID}; else source ${globalSettings}; fi;

# Export ALGORAND_DATA
export ALGORAND_DATA=${dataDir};

# Banner
echo -e "\n\n${brk}\nalgodMon - syncMonitor - Node Synchronization Monitor\n${brk}";

# Goal - Check Status
echo -e "\n\n${brk}\nNode Synchronization Check\n${brk}";
echo -e "\nProcessing:  ${nodeDir}/goal node status\n"
${nodeDir}/goal node status 2> ${sourceDir}/lastStatus.err > ${sourceDir}/lastStatus;

# Goal - Error handling
errorCheck=$(echo $?)
if [[ ${errorCheck} -gt 0 ]]; then 
        echo -e "\nError:  Execution failed\nExit status:  $?";
        echo -e "\n\n${brks}\nNext Step\n${brks}\nPlease retry manual execution of the command:\n\t${nodeDir}/goal node status\n\nCheck log files:"
        echo -e "\t${sourceDir}/lastStatus\n\t${dataDir}/lastStatus.err\n\t${ALGORAND_DATA}/node.log\n\n";
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
