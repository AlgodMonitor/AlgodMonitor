#!/bin/bash
#
#  algodMon v1.2 - voteMonitor - Consensus Vote Monitor
#
#  Copyright 2021 - Consiglieri-cfi
#

# Initialization
globalValues=$(dirname "$0")/../config/globalValues.cfg;
if [ ! -f ${globalValues} ]; then
echo -e "\n\nERROR: Missing configuration file!\n\nExpected Path: ${globalValues}\n\n";
kill ${BASHPID}; else source ${globalValues}; fi;

# Banner
echo -e "\n\n${brk}\nalgodMon - voteMonitor - Consensus Vote Monitor - Initialization\n${brk}";

# Configuration - Part Key Address
if [ -f ${configDir}/partWallet.cfg ]; then
source ${configDir}/partWallet.cfg;
echo -e "\n\nLoaded configuration: ${configDir}/partWallet.cfg\n\nParticipation Wallet: ${participationWallet}\n";
else
echo -e "${brkm}\nEnter Participation Account\n${brkm}\n"
echo -e "Please enter the address for your participation key...\n"
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
if [ ! -f ${logDir}/pastVote.src ]; then
echo -e "\n\n$(date) \t voteMonitor \t ERR \t Vote Count: No previous total found. File '${logDir}/pastVote.src' does not yet exist.\n" | tee -a ${logDir}/pastError.log
pastVotes=0; dailyVotes=0; totalVotes=0;
else
source ${logDir}/pastVote.src;
echo -e "\n\nLoaded configuration: ${logDir}/pastVote.src\n\nPrevious vote count: ${pastVotes}\n"
fi;

# Execution Tracker
echo -e "\n\nLast Executed: $(date -r ${logDir}/pastVote.src +"%Y-%m-%d %H:%M:%S" 2>/dev/null)\nCurrent Time:  ${currentDate} ${currentSecond}\n"

# Count - Update
currentVotes=$(grep -a VoteBroadcast ~/node/data/node.log | grep ${participationWallet} | wc -l); 
totalVotes=$(expr ${pastVotes} + ${currentVotes});
dailyVotes=$(expr $(grep ${currentDate} ${logDir}/monitorVotes.log | awk '{sum+=$4}END{print sum}') + ${currentVotes})

# Count - Write
echo -e "pastVotes=${totalVotes}" > ${logDir}/pastVote.src
echo -e "${currentTime} \t ${pastVotes} \t ${currentVotes} \t ${dailyVotes} \t ${totalVotes}" >> ${logDir}/monitorVotes.log

# Count - Report
echo -e "\n\n${brk}\nalgodMon - voteMonitor - Consensus Vote Monitor - Report\n${brk}\n";
echo -e "Date Time Previous New Today Total\n$(tail -n 20 ${logDir}/monitorVotes.log)" | column -t

# Call Error Monitor
echo -e "\n\n${brks}\nLog Cleanup\n${brks}\n\nCalling 'errorMonitor' to report errors and truncate node log...\n\n";
${sourceDir}/../error-monitor/error-monitor.sh;

# EOF
