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
bk=$(printf '=%.0s' {0..50}); brk=$(printf '=%.0s' {1..60}); brks=$(printf '=%.0s' {1..30});
sourceDir=$(dirname "$0");
logDir=${sourceDir}/../logs;
configDir=${sourceDir}/../config;
currentEpoch=$(date +%s);
export ALGORAND_DATA=~/node/data;
nodePath=$(echo ${ALGORAND_DATA} | sed 's/\/node\/data/\/node/g');

# Network monitor report
echo -e "\n\n${brk}\nalgodMon - networkMonitor - Network Monitor Report\n${brk}";
echo -e "\n${bk}\nNetwork Peers\n${bk}\n";

# Peer Connections - 'lsof -i'
timeout 10 lsof -i :4160 | awk '{print $(NF-1)}' | awk -F"->" '{print $2}' | awk -F":" '{print $1}' | awk 'NF' > ${logDir}/lsof-4160-${currentEpoch}

# Peer Connections - summary
cat $(find ${logDir}/ -name 'lsof-4160*' -mtime -7) | sort | uniq -c > ${logDir}/monitorPeers

# Remove 'lsof -i'
rm -f ${logDir}/lsof-4160-${currentEpoch}
