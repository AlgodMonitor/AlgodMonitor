#!/bin/bash
#
#  algodMon v1.2 - networkMonitor - Network Monitor Report
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
echo -e "\n\n${brk}\nalgodMon - networkMonitor - Network Monitor Report\n${brk}";
echo -e "\n${brkm}\nNetwork Peers\n${brkm}\n";

# Peer Connections - 'lsof -i'
timeout 10 lsof -i :4160 | awk '{print $(NF-1)}' | awk -F"->" '{print $2}' | awk -F":" '{print $1}' | awk 'NF' > ${logDir}/networkPeers/lsof-4160-${currentEpoch}

# Peer Connections - summary
cat $(find ${logDir}/networkPeers -name 'lsof-4160*' -mtime -7) | sort | uniq -c | sort -n | tee ${logDir}/networkPeers/monitorPeers-${currentEpoch}

# Remove 'lsof -i'
echo -e "\n\nRemoving temporary files:  ${logDir}/lsof-4160-${currentEpoch}\n\n"
rm -f ${logDir}/lsof-4160-${currentEpoch}