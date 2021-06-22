#!/bin/bash
#
#  algodMon v1.1 - partkeyMonitor - Participation Key Expiration
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

# Export ALGORAND_DATA
export ALGORAND_DATA=~/node/data;

# Banner
echo -e "\n\n${brk}\nalgodMon - partkeyMonitor - Participation Key Expiration - Initialization\n${brk}";

# Execution Tracker
echo -e "\n\nLast Executed: $(date -r ${logDir}/monitorKeyExpiration.log +"%Y-%m-%d %H:%M:%S" 2>/dev/null)\nCurrent Time:  ${currentDate} ${currentSecond}\n"

# Check round
currentRound=$(~/node/goal node status | grep "Last committed" | awk '{print $NF}');
endRound=$(~/node/goal account listpartkeys | tail -n1 | awk '{print $5}');

# Calculate expiration
deltaRound=$(expr ${endRound} - ${currentRound});
deltaSeconds=$(expr ${deltaRound} \* 4);
deltaEpoch=$(expr ${currentEpoch} + ${deltaSeconds});
deltaDays=$(expr ${deltaSeconds} / 86400);

# Write statistics
monitorKeyExpiration=${deltaDays};
echo -e "monitorKeyExpiration=${monitorKeyExpiration}" > ${logDir}/monitorAlertExpire.log;

# Update Report
echo -e "${currentTime} ${currentRound} ${endRound} ${deltaRound} ${deltaDays} $(date -d @${deltaEpoch} +%Y-%m-%d-%H:%M:%S)" >> ${logDir}/monitorExpiration.log;

# Show Summary
echo -e "\nParticipation Key is valid for ${monitorKeyExpiration} days.";

# Show Report
echo -e "\n\n${brk}\nalgodMon - partkeyMonitor - Participation Key Expiration - Report\n${brk}\n";
echo -e "Date Time Current End Rounds Days Expiration\n$(tail -n 20 ${logDir}/monitorExpiration.log)" | column -t

#EOF
