#!/bin/bash
#
#  algodMon v1.3 - Error Monitor - Node Error Monitor
#
#  Copyright 2022 - Algod Monitor
#

# Initialization
globalValues=$(dirname "$0")/../config/globalValues.cfg;
if [ ! -f ${globalValues} ]; then
	echo -e "\n\nERROR: Missing configuration file!\n\nExpected Path: ${globalValues}\n\n";
	kill ${BASHPID}; 
else 
	source ${globalValues}; 
fi;

# Banner
echo -e "\n\n${brk}\nAlgod Monitor - errorMonitor - Node Error Monitor - Initialization\n${brk}";

# Execution Tracker
lastExec=$(date -r ${logDir}/monitorErrors.log +"%Y-%m-%d %H:%M:%S" 2>/dev/null)
echo -e "\nLast Executed: ${lastExec}\nCurrent Time:  ${currentDate} ${currentSecond}\n"

# Error Monitor - Processing
echo -e "\n\n${brk}\nalgodMon - errorMonitor - Node Error Monitor - Processing\n${brk}\n";

# Set File Names
errorReport=${logDir}/nodeMessages/nodeError.log
warnReport=${logDir}/nodeMessages/nodeWarn.log

# Find last report
echo -e "Processing:  Finding last error report...";
lastEpochError=$(ls -1tr ${errorReport}-* 2> /dev/null | tail -n 1);
echo -e "Processing:  Finding last warning report...";
lastEpochWarn=$(ls -1tr ${warnReport}-* 2> /dev/null | tail -n 1);

# Node Log - Messages Parsers
echo -e "Processing:  Check 'node.log' for error messages...";
grep -a "err" ${dataDir}/node.log > ${errorReport};
echo -e "Processing:  Check 'node.log' for warning messages...";
grep -a "warn" ${dataDir}/node.log > ${warnReport};

# Node Log - Count Messages
echo -e "Processing:  Count error messages: ${errorReport}";
errorCount=$(wc -l ${errorReport} | awk '{print $1}');
echo -e "Processing:  Count warning messages: ${warnReport}"
warnCount=$(wc -l ${warnReport} | awk '{print $1}');

# Error Monitor - Report
echo -e "\n\n\n${brk}\nalgodMon - errorMonitor - Node Error Monitor - Report\n${brk}";

# errorReport - Errors Detected
mv ${errorReport} ${errorReport}-${currentEpoch};
echo -e "\n${brkm}\nError Report\n${brkm}";
if [[ ! ${errorCount} -gt 0 ]]; then
        echo -e "\nNo errors found in algod node log:  ${dataDir}/node.log\n";
else
	echo -e "\nALERT: Errors detected in algod node log:  ${dataDir}/node.log\n\n"
	tail ${errorReport}-${currentEpoch};
	echo -e "\n\nPlease review messages: ${errorReport}-${currentEpoch}\n"
fi;

# errorReport - Compare last report
if [[ ! -f ${lastEpochError} ]]; then
	echo -e "\nPrevious error report not found.\n";
else
	echo -e "\nProcessing:  Comparing last error report...";
	diff ${lastEpochError} ${errorReport}-${currentEpoch} > /dev/null 2>&1
	diffStatus=$(echo $?)
	if [[ ${diffStatus} == 0 ]]; then
		echo -e "\nCurrent error report is a duplicate of the previous file.\n\n\tCurrent Report: ${errorReport}-${currentEpoch}\n\tLast Report: ${lastEpochError}\n\n"
		echo -e "Removing duplicate report:  ${errorReport}-${currentEpoch}"
		rm -f ${errorReport}-${currentEpoch};
		dailyError=0;
	else
		echo -e "\nNew error messages have been reported.\n\n"
		dailyError=1;
	fi;
fi;

# errorReport - Warning Detected
mv ${warnReport} ${warnReport}-${currentEpoch};
echo -e "\n\n${brkm}\nWarning Report\n${brkm}";
if [[ ! ${warnCount} -gt 0 ]]; then
	echo -e "\nNo warnings found in algod log:  ${dataDir}/node.log\n";
else
	echo -e "\nALERT: Warnings detected in algod node log:  ${dataDir}/node.log\n\n"
	tail ${warnReport}-${currentEpoch};
	echo -e "\n\nPlease review messages: ${warnReport}-${currentEpoch}\n"
fi;

# errorReport - Compare last report
if [[ ! -f ${lastEpochWarn} ]]; then
	echo -e "\nPrevious error report not found.\n";
else
	echo -e "\nProcessing:  Comparing last warning report...";
	diff ${lastEpochWarn} ${warnReport}-${currentEpoch} > /dev/null 2>&1
	diffStatus=$(echo $?)
	if [[ ${diffStatus} == 0 ]]; then
		echo -e "\nCurrent warning report is a duplicate of the previous file.\n\n\tCurrent Report: ${warnReport}-${currentEpoch}\n\tLast Report: ${lastEpochWarn}\n\n"
		echo -e "Removing duplicate report:  ${errorReport}-${currentEpoch}"
		rm -f ${warnReport}-${currentEpoch};
		dailyWarn=0;
	else
		echo -e "\nNew error messages have been reported.\n\n"
		dailyWarn=1;
	fi; 
fi;

# Error Monitor - Historical
echo -e "\n\n${brk}\nalgodMon - errorMonitor - Node Error Monitor - History\n${brk}\n";
errorHistory=${logDir}/monitorErrors.log

# Count - Update
if [ -f ${errorHistory} ]; then
	if [ ${dailyError} -gt 0 ]; then
		dailyError=$(expr $(grep ${currentDate} ${errorHistory} | awk '{sum+=$3}END{print sum}') + ${errorCount});
		echo -e "dailyError=${dailyError}" > ${sourceDir}/lastCountError.src
	else
		source ${sourceDir}/lastCountError.src 2>/dev/null;
	fi;
	if [ ${dailyWarn} -gt 0 ]; then
		dailyWarn=$(expr $(grep ${currentDate} ${errorHistory} | awk '{sum+=$5}END{print sum}') + ${warnCount});
		echo -e "dailyWarn=${dailyWarn}" > ${sourceDir}/lastCountWarn.src
	else
		source ${sourceDir}/lastCountWarn.src 2>/dev/null;
	fi; 
fi;

# Truncate Node Log
echo -e "\nTruncating node log...\n"
sizeBefore=$(du -xL ${dataDir}/node.log | awk '{print $1}')
truncate -s 0 ${dataDir}/node.log
truncateStatus=${?}
sizeAfter=$(du -xL ${dataDir}/node.log | awk '{print $1}')
echo -e "\nExit Status: ${truncateStatus}\n"
echo -e "\n\tOld Size: ${sizeBefore}\n\tNew Size: ${sizeAfter}\n\n"

# Check File System Type
logFS=$(stat -f -c %T ${dataDir}/node.log);

# Count - Write
echo -e "${currentTime} \t ${errorCount} \t ${warnCount} \t ${dailyError} \t ${dailyWarn} \t ${truncateStatus} \t ${sizeAfter} \t ${sizeBefore} \t ${logFS}" >> ${errorHistory};

# Count - Display
echo -e "Date Time Error Warning Err_Total Warn_Total Truncate SizeNew SizeOld FS_Type\n$(tail -n 20 ${errorHistory})" | column -t;

# EOF
