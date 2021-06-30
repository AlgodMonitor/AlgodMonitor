#!/bin/bash
#
#  algodMon v1.2 - tokenMonitor - Token Report
#
#  Copyright 2021 - Consiglieri-cfi
#

# Initialization
globalValues=$(dirname "$0")/../config/globalValues.cfg;
if [ ! -f ${globalValues} ]; then
echo -e "\n\nERROR: Missing configuration file!\n\nExpected Path: ${globalValues}\n\n";
kill ${BASHPID}; else source ${globalValues}; fi;

# Export ALGORAND_DATA
export ALGORAND_DATA=~/node/data;

# Banner
echo -e "\n\n${brk}\nalgodMon - tokenMonitor - Account Balance Monitor - Report\n${brk}";

# Configuration - Add Wallet
if [ ! -f ${configDir}/monitorWallets.cfg ]; then
echo -e "\n${brkm}\nConfiguration\n${brkm}\n";
echo -e "You have not added monitoring for any public wallet addresses.\n\nDo you want to add any wallets to monitoring? (y/n)\n\n";
read configMonitor;
if [[ ${configMonitor} == "y" ]]; then
echo -e "\n\nEnter the wallet address to monitor...\n\n"; read monitorWallet;
echo -e "\n\nEnter a name for the account (no spaces)...\n\n"; read monitorName;
echo -e "\n\nYou entered the following address:\n\n\t${monitorWallet}\n\t${monitorName}\n\n\nIs this correct? (y/n)\n\n";
read validateAddress;
if [[ ${validateAddress} == "y" ]]; then
echo "${monitorName} ${monitorWallet}" >> ${configDir}/monitorWallets.cfg;
fi; fi; fi;

## Modification ## START ##
activateFunction=0
if [ "${activateFunction}" = "1" ]; then
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

fi;
## Modification ## END ##


# Supply Monitor
echo -e "\n${brkm}\nSupply Metrics\n${brkm}\n";
${nodeDir}/goal ledger supply;

# Supply History
currentSupply=$(${nodeDir}/goal ledger supply | grep Total);
echo -e "\n${brkm}\nSupply History\n${brkm}\n"; echo -e "${currentTime} \t ${currentSupply}" >> ${logDir}/monitorSupply.log;
head -n1 ${logDir}/monitorSupply.log;
tail ${logDir}/monitorSupply.log;

# Stake History
currentOnlineStake=$(${nodeDir}/goal ledger supply | grep Online);
echo -e "\n${brkm}\nOnline Stake\n${brkm}\n"; echo -e "${currentTime} \t ${currentOnlineStake}" >> ${logDir}/monitorOnlineStake.log;
head -n1 ${logDir}/monitorOnlineStake.log;
tail ${logDir}/monitorOnlineStake.log;

# Account Monitor
if [ -f ${configDir}/monitorWallets.cfg ]; then
echo -e "\n\n\n${brk}\nalgodMon - tokenMonitor - Account Monitor - ${currentDate}\n${brk}";
while read walletName walletAddress; do
	walletPrefix=${walletName}-$(echo ${walletAddress} | cut -c1-7);
	walletBalance=$(${nodeDir}/goal account balance -a ${walletAddress});
	echo -e "\n${brkm}\n${walletName}\n${brkm}\n";
	echo -e "${currentTime} \t ${walletBalance}" >> ${logDir}/walletBalance-${walletPrefix};
	head -n 1 ${logDir}/walletBalance-${walletPrefix};
	tail ${logDir}/walletBalance-${walletPrefix};
done < ${configDir}/monitorWallets.cfg
fi;
