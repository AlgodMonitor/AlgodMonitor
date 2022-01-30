#!/bin/bash
#
#  Algod Monitor v1.3 - Vote Monitor - Consensus Vote Monitor
#
#  Copyright 2022 - Algod Monitor
#

# Initialization
globalValues=$(dirname "$0")/../config/globalValues.cfg;
if [ ! -f ${globalValues} ]; then
echo -e "\n\nERROR: Missing configuration file!\n\nExpected Path: ${globalValues}\n\n";
kill ${BASHPID}; else source ${globalValues}; fi;

# Banner
echo -e "\n\n${brk}\nAlgod Monitor - Vote Monitor - Consensus Vote Monitor\n${brk}";

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
lastExec=$(date -r ${logDir}/pastVote.src +"%Y-%m-%d %H:%M:%S" 2>/dev/null)
echo -e "\n\nLast Executed: ${lastExec}\nCurrent Time:  ${currentDate} ${currentSecond}\n"

# Count - Update
currentVotes=$(grep -a VoteBroadcast ${dataDir}/node.log | grep ${participationWallet} | wc -l); 
totalVotes=$(expr ${pastVotes} + ${currentVotes});
dailyVotes=$(expr $(grep ${currentDate} ${logDir}/monitorVotes.log | awk '{sum+=$4}END{print sum}') + ${currentVotes})

# Count - Write
echo -e "pastVotes=${totalVotes}" > ${logDir}/pastVote.src
echo -e "${currentTime} \t ${pastVotes} \t ${currentVotes} \t ${dailyVotes} \t ${totalVotes}" >> ${logDir}/monitorVotes.log

# Count - Report
echo -e "\n\n${brk}\nalgodMon - voteMonitor - Consensus Vote Monitor - Report\n${brk}\n";
echo -e "Date Time Previous New Today Total\n$(tail -n 20 ${logDir}/monitorVotes.log)" | column -t

# Run Consensus Monitor
#  After 'consensus-monitor.sh' is called the votes are logged for reporting via telemetry
#  This function is commented out until the next release
# ${sourceDir}/../consensus-monitor/consensus-monitor.sh

# Call Error Monitor
#  After 'vote-monitor.sh' is called the 'error-monitor.sh' must be called after.
#  After 'error-monitor.sh' is called the errors are logged and the log file is truncated.
echo -e "\n\n${brks}\nLog Cleanup\n${brks}\n\nCalling 'errorMonitor' to report errors and truncate node log...\n\n";
${sourceDir}/../error-monitor/error-monitor.sh;

# EOF
