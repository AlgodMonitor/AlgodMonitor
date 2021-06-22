#!/bin/bash
#
#  algodMon v1.1 - voteMonitor - Consensus Vote Monitor
# 
#  Registration: OBQIVIPTUXZENH2YH3C63RHOGS7SUGGQTNJ52JR6YFHEVFK5BR7BEYKQKI
#
#  Copyright 2021 - Consiglieri-cfi
#

# Initialization
globalSettings=$(dirname "$0")/../config/globalSettings.cfg;
if [ ! -f ${globalSettings} ]; then
echo -e "\n\nERROR: Missing configuration file!\n\nExpected Path: ${globalSettings}\n\n";
kill ${BASHPID}; else source ${globalSettings}; fi;

# Banner
echo -e "\n\n${brk}\nalgodMon - voteMonitor - Consensus Vote Monitor - Initialization\n${brk}";

# Configuration - Part Key Address
if [ -f ${configDir}/partWallet.cfg ]; then
source ${configDir}/partWallet.cfg;
echo -e "\n\nLoaded configuration: ${configDir}/partWallet.cfg\n\nParticipation Wallet: ${participationWallet}\n";
else
echo -e "\n\nPlease enter the address for your participation key...\n"
read participationWallet;
echo -e "\n\nYou have entered the following account..\n\n\t${participationWallet}\n"
echo -e "\n\nIs this value correct? (y/n)\n\n"; read validateKey;
if [ $validateKey = "y" ]; then
echo -e "\n\nWriting configuration file..."
echo -e "participationWallet=${participationWallet}" > ${configDir}/partWallet.cfg
echo -e "\n\nDone."
else
echo -e "\n\nPlease run again to retry key entry.\n\n"
kill $BASHPID;
fi; fi;

# Vote Count - Previous Total
if [ ! -f ${sourceDir}/pastVote.src ]; then
echo -e "\n\nVote Count: No previous total found. File '${sourceDir}/pastVote.src' does not yet exist.\n"
pastVotes=0; dailyVotes=0; totalVotes=0;
else
source ${sourceDir}/pastVote.src;
echo -e "\n\nLoaded configuration: ${sourceDir}/pastVote.src\n\nPrevious vote count: ${pastVotes}\n"
fi;

# Execution Tracker
echo -e "\n\nLast Executed: $(date -r ${sourceDir}/pastVote.src +"%Y-%m-%d %H:%M:%S")\nCurrent Time:  ${currentDate} ${currentSecond}\n"

# Count - Update
currentVotes=$(grep -a VoteBroadcast ~/node/data/node.log | grep ${participationWallet} | wc -l); 
totalVotes=$(expr ${pastVotes} + ${currentVotes});
dailyVotes=$(expr $(grep ${currentDate} ${logDir}/totalVotes.log | awk '{sum+=$4}END{print sum}') + ${currentVotes})

# Count - Write
echo -e "pastVotes=${totalVotes}" > ${sourceDir}/pastVote.src
echo -e "${currentTime} \t ${pastVotes} \t ${currentVotes} \t ${dailyVotes} \t ${totalVotes}" >> ${logDir}/totalVotes.log

# Count - Report
echo -e "\n\n${brk}\nalgodMon - voteMonitor - Consensus Vote Monitor - Report\n${brk}\n";
echo -e "Date Time Previous New Today Total\n$(tail -n 20 ${logDir}/totalVotes.log)" | column -t

# Call Error Monitor
echo -e "\n\n\nCalling 'errorMonitor' to report errors and truncate node log...\n\n";
${sourceDir}/../errorMonitor/errorMonitor.sh;

# EOF
