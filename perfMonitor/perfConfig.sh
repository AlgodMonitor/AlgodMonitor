#!/bin/bash

# Initialization
globalValues=$(dirname "$0")/../config/globalValues.cfg;
if [ ! -f ${globalValues} ]; then
echo -e "\n\nERROR: Missing configuration file!\n\nExpected Path: ${globalValues}\n\n";
kill ${BASHPID}; else source ${globalValues}; fi;

# Variables
for classType in reportType reportFormat; do export ${classType}=0; done;
reportType=$1;

# Report Selector
if [ "${reportType}" = "check" ]; then
viewCheck=1;
elif [ "${reportType}" = "enable" ]; then
viewEnable=1;
elif [ "${reportType}" = "disable" ]; then
viewDisable=1;
elif [ "${reportType}" = "monitor" ]; then
viewMonitor=1;
else
echo -e "\n\n${brk}\nalgodMon - perfConfig - Performance Configuration Utility\n${brk}\n";
echo -e "\nView and change settings related to performance monitoring.\n\nPlease specify an option when running the 'perfConfig' command.\n";
echo -e "\nExample:\n\t ./perfConfig.sh check \n\t ./perfConfig.sh enable \n\t ./perfConfig.sh disable \n";
echo -e "\nOptions:\n\t check \n\t enable \n\t disable \n\t monitor\n\n";
echo -e "\nEnter an option...\n\n"; read selectOption;
echo -e "\n\n\nDisplaying ${reportType} report...\n";
${sourceDir}/perfConfig.sh ${selectOption};
fi;

# Redirect - Monitor
if [ "${viewMonitor}" = "1" ]; then
echo -e "\nExecuting: ${sourceDir}/perfMonitor.sh\n"
${sourceDir}/perfMonitor.sh;
fi;

# Config - Check settings and service state
if [ "${viewCheck}" = "1" ]; then
echo -e "\n\n${brk}\nalgodMon - perfConfig - Check settings and service state\n${brk}";
echo -e "\n${brkm}\nConfiguration: 'sysstat' service\n${brkm}\n";
grep "^ENABLED=" /etc/default/sysstat
echo -e "\n${brkm}\nStatus: 'sysstat' service\n${brkm}\n";
systemctl status sysstat
fi;

# Config - Statistics Collection - Enable
if [ "${viewEnable}" = "1" ]; then
echo -e "\n\n${brk}\nalgodMon - perfConfig - Statistics Collection - Enable\n${brk}";
echo -e "\n${brkm}\nConfiguration: 'sysstat' service\n${brkm}\n";
grep "^ENABLED=" /etc/default/sysstat;
echo -e "\n\n${brkm}\nConfirmation\n${brkm}\n";
echo -e "Do you want to enable statistics collection? (y/n)\n\n"; read validateChange;
if [ "${validateChange}" = "y" ]; then
echo -e "\n${brkm}\nConfiguration: 'sysstat' service\n${brkm}\n";
echo -e "Enabling statistics collection...\n";
sudo sed -i 's/^ENABLED=.*/ENABLED=\"true\"/g' /etc/default/sysstat
echo -e "\n$(timeout 2 grep "^ENABLED=" /etc/default/sysstat)\n\n";
else
echo -e "\n${brkm}\nConfiguration: 'sysstat' service\n${brkm}\n";
echo -e "No changes have been made.\n"
grep "^ENABLED=" /etc/default/sysstat
fi; fi;

# Config - Statistics Collection - Disable
if [ "${viewDisable}" = "1" ]; then
echo -e "\n\n${brk}\nalgodMon - perfConfig - Statistics Collection - Disable\n${brk}";
echo -e "\n${brkm}\nConfiguration: 'sysstat' service\n${brkm}\n";
grep "^ENABLED=" /etc/default/sysstat;
echo -e "\n\n${brkm}\nConfirmation\n${brkm}\n";
echo -e "Do you want to disable statistics collection? (y/n)\n\n"; read validateChange;
if [ "${validateChange}" = "y" ]; then
echo -e "\n${brkm}\nConfiguration: 'sysstat' service\n${brkm}\n";
echo -e "Disabling statistics collection...\n";
sudo sed -i 's/^ENABLED=.*/ENABLED=\"false\"/g' /etc/default/sysstat
echo -e "\n$(timeout 2 grep "^ENABLED=" /etc/default/sysstat)\n\n";
else
echo -e "\n${brkm}\nConfiguration: 'sysstat' service\n${brkm}\n";
echo -e "No changes have been made.\n"
grep "^ENABLED=" /etc/default/sysstat
fi; fi;
