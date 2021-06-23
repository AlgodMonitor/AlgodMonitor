#!/bin/bash
#
#  algodMon v1.2 - partkeyMonitor - Participation Key Expiration
#
#  Copyright 2021 - Consiglieri-cfi
#

# Initialization
globalValues=$(dirname "$0")/../config/globalValues.cfg;
if [ ! -f ${globalValues} ]; then
echo -e "\n\nERROR: Missing configuration file!\n\nExpected Path: ${globalValues}\n\n";
kill ${BASHPID}; else source ${globalValues}; fi;

# Export ALGORAND_DATA
export ALGORAND_DATA=${dataDir};

# Banner
echo -e "\n\n${brk}\nalgodMon - partkeyMonitor - Participation Key Expiration - Initialization\n${brk}";

# Execution Tracker
echo -e "\n\nLast Executed: $(date -r ${logDir}/monitorExpiration.log +"%Y-%m-%d %H:%M:%S" 2>/dev/null)\nCurrent Time:  ${currentDate} ${currentSecond}\n"

# Check round
currentRound=$(${nodeDir}/goal node status | grep "Last committed" | awk '{print $NF}');
keyState=$(${nodeDir}/goal account listpartkeys | tail -n1 | awk '{print $1, $5}');
registerState=$(echo ${keyState} | awk '{print $1}');
lastRound=$(echo ${keyState} | awk '{print $2}');


# Calculate expiration
deltaRound=$(expr ${lastRound} - ${currentRound});
deltaSeconds=$(expr ${deltaRound} \* 4);
deltaEpoch=$(expr ${currentEpoch} + ${deltaSeconds});
deltaDays=$(expr ${deltaSeconds} / 86400);

# Write statistics
monitorKeyExpiration=${deltaDays};
echo -e "monitorKeyExpiration=${monitorKeyExpiration}" > ${logDir}/monitorAlertExpire.log;

# Update Report
echo -e "${currentTime} \t ${currentRound} \t ${lastRound} \t ${deltaRound} \t ${deltaDays} \t $(date -d @${deltaEpoch} +%Y-%m-%d-%H:%M:%S) \t ${registerState}" >> ${logDir}/monitorExpiration.log;

# Show Summary
echo -e "\nParticipation Key is valid for ${monitorKeyExpiration} days.";

# Show Report
echo -e "\n\n${brk}\nalgodMon - partkeyMonitor - Participation Key Expiration - Report\n${brk}\n";
echo -e "Date Time Current End RoundsLeft DaysLeft Expiration Registered\n$(tail -n 20 ${logDir}/monitorExpiration.log)" | column -t

#EOF
