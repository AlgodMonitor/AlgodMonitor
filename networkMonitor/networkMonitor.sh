#!/bin/bash
#
#  algodMon v1.1 - networkMonitor - Network Monitor Report
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
export ALGORAND_DATA=${dataDir};

# Banner
echo -e "\n\n${brk}\nalgodMon - networkMonitor - Network Monitor Report\n${brk}";
echo -e "\n${bk}\nNetwork Peers\n${bk}\n";

# Peer Connections - 'lsof -i'
timeout 10 lsof -i :4160 | awk '{print $(NF-1)}' | awk -F"->" '{print $2}' | awk -F":" '{print $1}' | awk 'NF' > ${logDir}/networkPeers/lsof-4160-${currentEpoch}

# Peer Connections - summary
cat $(find ${logDir}/networkPeers -name 'lsof-4160*' -mtime -7) | sort | uniq -c | tee ${logDir}/networkPeers/monitorPeers-{currentEpoch}

# Remove 'lsof -i'
rm -f ${logDir}/lsof-4160-${currentEpoch}
