#!/bin/bash
#
#  Algod Monitor - v1.3 - Network Monitor - Network Monitor Report
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
echo -e "\n\n${brk}\nAlgod Monitor - Network Monitor - Network Monitor Report\n${brk}";
echo -e "\n${brkm}\nNetwork Peers\n${brkm}\n";

# Peer Connections - 'lsof -i'
timeout 10 lsof -i :4160 | awk '{print $(NF-1)}' | awk -F"->" '{print $2}' | awk -F":" '{print $1}' | awk 'NF' > ${logDir}/networkPeers/lsof-4160-${currentEpoch}

# Peer Connections - summary
reportList=$(find ${logDir}/networkPeers -name 'lsof-4160*' -mtime -7)
cat ${reportList} | sort | uniq -c | sort -n | tee ${logDir}/networkPeers/monitorPeers-${currentEpoch}


