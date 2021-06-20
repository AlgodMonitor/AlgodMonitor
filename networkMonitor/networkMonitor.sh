#!/bin/bash
#
#  algodMon v1.0 - networkMonitor - Network Monitor Report
# 
#  Donate/Register: OBQIVIPTUXZENH2YH3C63RHOGS7SUGGQTNJ52JR6YFHEVFK5BR7BEYKQKI
#
#  Copyright 2021 - Consiglieri-cfi
#

# Set variables
#
bk=$(printf '=%.0s' {0..50}); brk=$(printf '=%.0s' {1..60}); brks=$(printf '=%.0s' {1..30});
sourceDir=$(dirname "$0");
currentEpoch=$(date +%s);
export ALGORAND_DATA=~/node/data;
nodePath=$(echo ${ALGORAND_DATA} | sed 's/\/node\/data/\/node/g');

# Network monitor report
echo -e "\n\n${brk}\nalgodMon - networkMonitor - Network Monitor Report\n${brk}";
echo -e "\n${bk}\nNetwork Peers\n${bk}\n";

# Process netstat
netstat -natp 2>/dev/null > ${sourceDir}/netstat-${currentEpoch}
grep algod ${sourceDir}/netstat-${currentEpoch} | awk '{print $5}' > ${sourceDir}/peersCurrent.log

# Lookup peers
while read ipAddr; do nslookup $(echo $ipAddr | awk -F: '{print $1}'); done < ${sourceDir}/peersCurrent.log | grep "name =" | tee -a peersCurrentLookup.log

# Remove netstat
rm -f ${sourceDir}/netstat-${currentEpoch}
