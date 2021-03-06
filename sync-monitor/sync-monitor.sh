#!/bin/bash
#
#  Algod Monitor - v1.3 - Sync Monitor - Node Synchronization Monitor
#
#  Copyright 2022 - Algod Monitor
#

# Initialization
globalValues=$(dirname "$0")/../config/globalValues.cfg;
if [ ! -f ${globalValues} ]; then
echo -e "\n\nERROR: Missing configuration file!\n\nExpected Path: ${globalValues}\n\n";
kill ${BASHPID}; else source ${globalValues}; fi;

# Export ALGORAND_DATA
export ALGORAND_DATA=${dataDir};

# Banner
echo -e "\n\n${brk}\nAlgod Monitor - Sync Monitor - Node Synchronization Monitor\n${brk}";

# Goal - Check Status
echo -e "\n\n${brkm}\nNode Synchronization Check\n${brkm}";
echo -e "\nProcessing:  ${nodeDir}/goal node status\n"
${nodeDir}/goal node status 2> ${sourceDir}/lastStatus.err 1> ${sourceDir}/lastStatus;

# Goal - Error handling
errorCheck=$(echo $?)
if [[ ${errorCheck} -gt 0 ]]; then 
        echo -e "\nError:  Execution failed\nExit status:  ${errorCheck}\n";
        echo -e "$(date) \t syncMonitor \t ERR \t Non-zero exit status: ${errorCheck} \t ./node/goal node status" | tee -a ${logDir}/pastError.log;
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
echo -e "${currentTime} \t ${diskMonitor} \t ${lastBlock} \t ${syncMonitor} \t ${syncTime}" >> ${logDir}/monitorSync.log;

# Synchronization - Report
echo -e "\n${brk}\nNode Synchronization Report\n${brk}\n";
echo -e "Date Time Disk_Util Last_Block Round Sync\n$(head -n 1 ${logDir}/monitorSync.log)\n$(tail -n 17 ${logDir}/monitorSync.log)" | column -t
