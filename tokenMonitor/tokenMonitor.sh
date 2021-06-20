#!/bin/bash
#
#  algodMon v1.1 - tokenMonitor - Token Report
# 
#  Donate/Register: OBQIVIPTUXZENH2YH3C63RHOGS7SUGGQTNJ52JR6YFHEVFK5BR7BEYKQKI
#
#  Copyright 2021 - Consiglieri-cfi
#

# Initialization
export ALGORAND_DATA=~/node/data;
nodeDir=~/node;
nodePath=~/node;
sourceDir=$(dirname "$0");
currentDate=$(date +%Y-%m-%d);
currentSecond=$(date +%H:%M:%S);
currentEpoch=$(date +%s);
currentTime=$(echo -e "${currentDate}  ${currentSecond}");
brk=$(printf '=%.0s' {1..120}); brkm=$(printf '=%.0s' {1..70}); brks=$(printf '=%.0s' {1..30});
echo -e "\n\n${brk}\nalgodMon - tokenMonitor - Token Report - ${currentDate}\n${brk}";

# Configuration - Add Wallet
if [ ! -f ${sourceDir}/walletAddress.cfg ]; then
echo -e "\n${brkm}\nConfiguration\n${brkm}\n";
echo -e "You have not added monitoring for any public wallet addresses.\n\nDo you want to add any wallets to monitoring? (y/n)\n\n";
read configMonitor;
if [[ ${configMonitor} == "y" ]]; then
echo -e "\n\nEnter the wallet address to monitor...\n\n"; read monitorWallet;
echo -e "\n\nEnter a name for the account...\n\n"; read monitorName;
echo -e "\n\nYou entered the following address:\n\n\t${monitorWallet}\n\t${monitorName}\n\n\nIs this correct? (y/n)\n\n";
read validateAddress;
if [[ ${validateAddress} == "y" ]]; then
echo "${monitorName} ${monitorWallet}" >> ${sourceDir}/walletAddress.cfg;
fi; fi; fi;

# Supply Monitor
echo -e "\n${brkm}\nSupply Metrics\n${brkm}\n";
${nodeDir}/goal ledger supply;

# Supply History
echo -e "\n${brkm}\nSupply History\n${brkm}\n"; echo -e "${currentTime} \t $(${nodeDir}/goal ledger supply | grep Total)" >> ${sourceDir}/supplyMonitor.log;
head -n1 ${sourceDir}/supplyMonitor.log;
tail ${sourceDir}/supplyMonitor.log;

# Stake History
echo -e "\n${brkm}\nOnline Stake\n${brkm}\n"; echo -e "${currentTime} \t $(${nodeDir}/goal ledger supply | grep -i online)" >> ${sourceDir}/onlineMonitor.log;
head -n1 ${sourceDir}/onlineMonitor.log;
tail ${sourceDir}/onlineMonitor.log;

# Account Monitor
if [ -f ${sourceDir}/walletAddress.cfg ]; then
echo -e "\n\n${brk}\nalgodMon - tokenMonitor - Account Monitor - ${currentDate}\n${brk}";
while read walletName walletAddress; do
	walletPrefix=${walletName}-$(echo ${walletAddress} | cut -c1-7);
	echo -e "\n${brkm}\n${walletName}\n${brkm}\n";
	echo -e "${currentTime} \t $(${nodeDir}/goal account balance -a ${walletAddress})" >> ${sourceDir}/walletBalance-${walletPrefix};
	head -n 1 ${sourceDir}/walletBalance-${walletPrefix};
	tail ${sourceDir}/walletBalance-${walletPrefix};
done < ${sourceDir}/walletAddress.cfg
fi;
