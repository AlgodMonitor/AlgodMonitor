#!/bin/bash
#
#  algodMon v1.1 - partkeyMonitor - Participation Key Expiration
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
brk=$(printf '=%.0s' {1..90}); brks=$(printf '=%.0s' {1..30});
echo -e "\n\n${brk}\nalgodMon - partkeyMonitor - Participation Key Expiration - Initialization\n${brk}";

# Execution Tracker
echo -e "\n\nLast Executed: $(date -r ${sourceDir}/monitorKeyExpiration.log +"%Y-%m-%d %H:%M:%S" 2>/dev/null)\nCurrent Time:  ${currentDate} ${currentSecond}\n"

# Check round
currentRound=$(~/node/goal node status | grep "Last committed" | awk '{print $NF}');
endRound=$(~/node/goal account listpartkeys | tail -n1 | awk '{print $5}');

# Calculate expiration
deltaRound=$(expr ${endRound} - ${currentRound});
deltaSeconds=$(expr ${deltaRound} \* 4);
deltaEpoch=$(expr ${currentEpoch} + ${deltaSeconds});
deltaDays=$(expr ${deltaSeconds} / 86400);

# Write statistics
monitorKeyExpiration=${deltaDays}
echo -e "monitorKeyExpiration=${monitorKeyExpiration}" > ${sourceDir}/monitorAlertExpire.log

# Update Report
echo -e "${currentTime} ${currentRound} ${endRound} ${deltaRound} ${deltaDays} $(date -d @${deltaEpoch} +%Y-%m-%d-%H:%M:%S)" >> ${sourceDir}/monitorExpiration.log;

# Show Summary
echo -e "\nParticipation Key is valid for ${monitorKeyExpiration} days.";

# Show Report
echo -e "\n\n${brk}\nalgodMon - partkeyMonitor - Participation Key Expiration - Report\n${brk}\n";
echo -e "Date Time Current End Rounds Days Expiration\n$(tail -n 20 ${sourceDir}/monitorExpiration.log)" | column -t

#EOF
