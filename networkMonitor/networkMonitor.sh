#!/bin/bash
#
#  algodMon v1.1 - networkMonitor - Network Monitor Report
# 
#  Donate/Register: OBQIVIPTUXZENH2YH3C63RHOGS7SUGGQTNJ52JR6YFHEVFK5BR7BEYKQKI
#
#  Copyright 2021 - Consiglieri-cfi
#

# Set variables
#
nodeDir=~/node;
sourceDir=$(dirname "$0");
logDir=${sourceDir}/../logs;
configDir=${sourceDir}/../config;
currentDate=$(date +%Y-%m-%d);
currentSecond=$(date +%H:%M:%S);
currentEpoch=$(date +%s);
currentTime=$(echo -e "${currentDate}  ${currentSecond}");
brk=$(printf '=%.0s' {1..120}); brkm=$(printf '=%.0s' {1..70}); brks=$(printf '=%.0s' {1..30});
export ALGORAND_DATA=~/node/data;
nodePath=$(echo ${ALGORAND_DATA} | sed 's/\/node\/data/\/node/g');

# Network monitor report
echo -e "\n\n${brk}\nalgodMon - networkMonitor - Network Monitor Report\n${brk}";
echo -e "\n${bk}\nNetwork Peers\n${bk}\n";

# Peer Connections - 'lsof -i'
timeout 10 lsof -i :4160 | awk '{print $(NF-1)}' | awk -F"->" '{print $2}' | awk -F":" '{print $1}' | awk 'NF' > ${logDir}/networkPeers/lsof-4160-${currentEpoch}

# Peer Connections - summary
cat $(find ${logDir}/networkPeers -name 'lsof-4160*' -mtime -7) | sort | uniq -c | tee ${logDir}/networkPeers/monitorPeers-{currentEpoch}

# Remove 'lsof -i'
rm -f ${logDir}/lsof-4160-${currentEpoch}
