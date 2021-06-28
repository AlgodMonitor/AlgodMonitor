#!/bin/bash
#
#  algodMon v1.2 - perfMonitor - Host Performance Monitor
#
#  Copyright (C) 2021 - Consiglieri-cfi
#

# Initialization
sourceDir=$(dirname "$0");
globalValues=${sourceDir}/../config/globalValues.cfg
if [ ! -f ${globalValues} ]; then
echo -e "\n\nERROR: Missing configuration file!\n\nExpected Path: ${globalValues}\n\n";
kill ${BASHPID}; else source ${globalValues}; fi;

perfDevices=${sourceDir}/../config/perfDevices.cfg
if [ ! -f ${perfDevices} ]; then
echo -e "\n\nERROR: Missing configuration file!\n\nExpected Path: ${perfDevices}\n\n";
echo -e "\n\nPlease run the configuration utility: ./perfConfig.sh devices\n\n";
kill ${BASHPID}; else source ${perfDevices}; fi;


# Variables
for classType in reportType reportFormat; do export ${classType}=0; done;
reportType=$1;

# Report Selector
if [ "${reportType}" = "avg" ]; then
viewAverage=1;
elif [ "${reportType}" = "full" ]; then
viewFull=1;
elif [ "${reportType}" = "cpu" ]; then
viewCPU=1;
elif [ "${reportType}" = "memory" ]; then
viewMemory=1;
elif [ "${reportType}" = "network" ]; then
viewNetwork=1;
elif [ "${reportType}" = "storage" ]; then
viewStorage=1;
elif [ "${reportType}" = "config" ]; then
viewConfig=1;
else
echo -e "\n\n${brk}\nalgodMon - perfMonitor - Performance Report Viewer\n${brk}\n";
echo -e "\nDisplay historical reports showing system resource utilization.\n\nPlease specify an option when running the 'perfMonitor' command.\n";
echo -e "\nExample:\n\t ./viewLogs.sh avg \n\t ./viewLogs.sh full \n\t ./viewLogs.sh memory \n";
echo -e "\nOptions:\n\t avg \n\t full \n\t cpu \n\t memory \n\t network \n\t storage \n\t config\n\n";
echo -e "\nEnter a report type...\n\n"; read reportType;
echo -e "\n\n\nDisplaying ${reportType} report...\n";
${sourceDir}/perfMonitor.sh ${reportType};
fi;

# Redirect - Config
if [ "${viewConfig}" = "1" ]; then
echo -e "\nExecuting: ${sourceDir}/perfConfig.sh\n";
${sourceDir}/perfConfig.sh;
fi;

# Report - Averages
if [ "${viewAverage}" = "1" ]; then
echo -e "\n\n${brk}\nalgodMon - perfMonitor - Load Averages Report\n${brk}";
echo -e "\n${brks}\nCPU\n${brks}";
sar -u | egrep "Average|nice";
echo -e "\n${brks}\nMemory\n${brks}";
sar -r | egrep "Average|kbmemfree";
echo -e "\n${brks}\nSwap - Used\n${brks}";
sar -S | egrep "Average|kbswpfree";
echo -e "\n${brks}\nSwap - Statistics\n${brks}";
sar -W | egrep "Average|pswpin"
echo -e "\n${brks}\nNetwork\n${brks}";
echo -e "00:00:00        IFACE   rxpck/s   txpck/s    rxkB/s    txkB/s   rxcmp/s   txcmp/s  rxmcst/s   %ifutil"
sar -n DEV -z | egrep "${nicName}" | egrep "Average";
echo -e "\n${brks}\nDisk IO - Performance\n${brks}";
sar -dpz | egrep "DEV|${storageName}" | egrep "Average";
echo -e "\n${brks}\nDisk IO - Blocks\n${brks}";
sar -b | egrep "bwrtn|Average";
fi;

# Report - Full
if [ "${viewFull}" = "1" ]; then
echo -e "\n\n${brk}\nalgodMon - perfMonitor - Full Daily Report\n${brk}";
echo -e "\n${brks}\nDisk IO - Performance\n${brks}";
echo -e "00:00:00          DEV       tps     rkB/s     wkB/s   areq-sz    aqu-sz     await     svctm     %util";
sar -dpz | egrep "${storageName}"
echo -e "\n${brks}\nDisk IO - Blocks\n${brks}";
sar -b
echo -e "\n${brks}\nNetwork\n${brks}";
echo -e "00:00:00        IFACE   rxpck/s   txpck/s    rxkB/s    txkB/s   rxcmp/s   txcmp/s  rxmcst/s   %ifutil";
sar -n DEV -z | egrep "${nicName}"
echo -e "\n${brks}\nMemory\n${brks}";
sar -r
echo -e "\n${brks}\nSwap - Utilization\n${brks}";
sar -S
echo -e "\n${brks}\nSwap - Statistics\n${brks}";
sar -S
echo -e "\n${brks}\nCPU\n${brks}";
sar -u
fi;

# Report - CPU
if [ "${viewCPU}" = "1" ]; then
echo -e "\n\n${brk}\nalgodMon - perfMonitor - Full Daily Report - CPU\n${brk}";
echo -e "\n${brks}\nCPU\n${brks}";
sar -u
fi;

# Report - Memory
if [ "${viewMemory}" = "1" ]; then
echo -e "\n\n${brk}\nalgodMon - perfMonitor - Full Daily Report - Memory\n${brk}";
echo -e "\n${brks}\nMemory\n${brks}";
sar -r
echo -e "\n${brks}\nSwap - Utilization\n${brks}";
sar -S
echo -e "\n${brks}\nSwap - Statistics\n${brks}";
sar -S
fi;


# Report - Network
if [ "${viewNetwork}" = "1" ]; then
echo -e "\n\n${brk}\nalgodMon - perfMonitor - Full Daily Report - Network\n${brk}";
echo -e "\n${brks}\nNetwork Performance\n${brks}";
echo -e "00:00:00        IFACE   rxpck/s   txpck/s    rxkB/s    txkB/s   rxcmp/s   txcmp/s  rxmcst/s   %ifutil";
sar -n DEV -z | egrep "${nicName}"
fi;

# Report - Storage
if [ "${viewStorage}" = "1" ]; then
echo -e "\n\n${brk}\nalgodMon - perfMonitor - Full Daily Report - Storage\n${brk}";
echo -e "\n${brks}\nDisk IO - Performance\n${brks}";
echo -e "00:00:00          DEV       tps     rkB/s     wkB/s   areq-sz    aqu-sz     await     svctm     %util";
sar -dpz | egrep "${storageName}"
echo -e "\n${brks}\nDisk IO - Blocks\n${brks}";
sar -b
fi;

