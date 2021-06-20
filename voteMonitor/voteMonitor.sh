#!/bin/bash
#
#  algodMon v1.1 - voteMonitor - Consensus Vote Monitor - 
# 
#  Registration: OBQIVIPTUXZENH2YH3C63RHOGS7SUGGQTNJ52JR6YFHEVFK5BR7BEYKQKI
#
#  Copyright 2021 - Consiglieri-cfi
#

# Initialization
sourceDir=$(dirname "$0");
currentDate=$(date +%Y-%m-%d);
currentSecond=$(date +%H:%M:%S);
currentEpoch=$(date +%s);
currentTime=$(echo -e "${currentDate}  ${currentSecond}");
brk=$(printf '=%.0s' {1..120}); brks=$(printf '=%.0s' {1..30});
echo -e "\n\n${brk}\nalgodMon - voteMonitor - Consensus Vote Monitor - Initialization\n${brk}";

# Configuration - Part Key Address
if [ -f ${sourceDir}/partWallet.src ]; then
source ${sourceDir}/partWallet.src;
echo -e "\n\nLoaded configuration: ${sourceDir}/partWallet.src\n\nParticipation Wallet: ${participationWallet}\n";
else
echo -e "\n\nPlease enter the address for your participation key...\n"
read participationWallet;
echo -e "\n\nYou have entered the following account..\n\n\t${participationWallet}\n"
echo -e "\n\nIs this value correct? (y/n)\n\n"; read validateKey;
if [ $validateKey = "y" ]; then
echo -e "\n\nWriting configuration file..."
echo -e "participationWallet=${participationWallet}" > partWallet.src
echo -e "\n\nDone."
else
echo -e "\n\nPlease run again to retry key entry.\n\n"
kill $BASHPID;
fi; fi;

# Vote Count - Previous Total
if [ ! -f ${sourceDir}/pastVote.src ]; then
echo -e "\n\nVote Count: No previous total found. File '${sourceDir}/pastVote.src' does not yet exist.\n"
pastVotes=0
else
source ${sourceDir}/pastVote.src;
echo -e "\n\nLoaded configuration: ${sourceDir}/pastVote.src\n\nPrevious vote count: ${pastVotes}\n"
fi;

# Execution Tracker
echo -e "\n\nLast Executed: $(date -r ${sourceDir}/pastVote.src +"%Y-%m-%d %H:%M:%S")\nCurrent Time:  ${currentDate} ${currentSecond}\n"

# Count - Update
currentVotes=$(grep -a VoteBroadcast ~/node/data/node.log | grep ${participationWallet} | wc -l); 
totalVotes=$(expr ${pastVotes} + ${currentVotes});
dailyVote=$(expr $(grep ${currentDate} ${sourceDir}/totalVote.log | awk '{sum+=$4}END{print sum}') + ${currentVotes})

# Count - Write
echo -e "pastVotes=${totalVotes}" > ${sourceDir}/pastVote.src
echo -e "${currentTime} \t ${pastVotes} \t ${currentVotes} \t ${dailyVote} \t ${totalVotes}" >> ${sourceDir}/totalVote.log

# Count - Report
echo -e "\n\n${brk}\nalgodMon - voteMonitor - Consensus Vote Monitor - Report\n${brk}\n";
echo -e "Date Time Previous Current Today Total\n$(tail -n 20 ${sourceDir}/totalVote.log)" | column -t

# Call Error Monitor
${sourceDir}/../errorMonitor/errorMonitor.sh;

# EOF
