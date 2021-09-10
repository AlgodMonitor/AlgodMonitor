#!/bin/bash
#
#  algodMon v1.2 - perfConfig - Host Performance Configuration
#
#  Copyright (C) 2021 - Consiglieri-cfi
#

# Initialization
globalValues=$(dirname "$0")/../config/globalValues.cfg;
if [ ! -f ${globalValues} ]; then
echo -e "\n\nERROR: Missing configuration file!\n\nExpected Path: ${globalValues}\n\n";
kill ${BASHPID}; else source ${globalValues}; fi;

# Variables
for classType in reportType reportFormat; do export ${classType}=0; done;
reportType=$1;

# Report Selector
if [ "${reportType}" = "status" ]; then
viewStatus=1;
elif [ "${reportType}" = "devices" ]; then
viewDevices=1;
elif [ "${reportType}" = "enable" ]; then
viewEnable=1;
elif [ "${reportType}" = "disable" ]; then
viewDisable=1;
elif [ "${reportType}" = "view" ]; then
viewRedirect=1;
else
echo -e "\n\n${brk}\nalgodMon - perfConfig - Performance Configuration Utility\n${brk}\n";
echo -e "\nView and change settings related to performance monitoring.\n\nPlease specify an option when running the 'perfConfig' command.\n";
echo -e "\nExample:\n\t ./perfConfig.sh devices \n\t ./perfConfig.sh status \n\t ./perfConfig.sh enable \n";
echo -e "\nOptions:\n\t devices \n\t status \n\t enable \n\t disable \n\t view\n\n";
echo -e "\nEnter an option...\n\n"; read selectOption;
${sourceDir}/perfConfig.sh ${selectOption};
fi;

# Redirect - Monitor
if [ "${viewRedirect}" = "1" ]; then
echo -e "\nExecuting: ${sourceDir}/perfMonitor.sh\n"
${sourceDir}/perfMonitor.sh;
fi;

# Config - Check settings and service state
if [ "${viewStatus}" = "1" ]; then
echo -e "\n\n${brk}\nalgodMon - perfConfig - Check settings and service state\n${brk}";
echo -e "\n${brkm}\nConfiguration: 'sysstat' service\n${brkm}\n";
grep "^ENABLED=" /etc/default/sysstat
echo -e "\n${brkm}\nStatus: 'sysstat' service\n${brkm}\n";
systemctl status sysstat
fi;

# Config - Device Selection
if [ "${viewDevices}" = "1" ]; then
perfDevices=${sourceDir}/../config/perfDevices.cfg;
echo -e "\n\n${brk}\nalgodMon - perfConfig - Device Selection\n${brk}";
echo -e "\nThe devices below will be used by 'perfMonitor' for reporting."
if [ ! -f ${perfDevices} ]; then
echo -e "\nWARNING: Configuration does not yet exist.\n";
echo -e "\n\nPlease specify network and storage devices for performance monitoring.\n\n";
else
source ${perfDevices};
echo -e "\n${brkm}\nCurrent Configuration\n${brkm}"
echo -e "\n${brks}\nNetwork Interface\n${brks}\n";
grep nicName ${perfDevices}
echo -e "\n${brks}\nStorage Device\n${brks}\n";
grep storageName ${perfDevices}
fi;
echo -e "\n\n\n${brkm}\nConfiguration Changes\n${brkm}\n"
echo -e "Do you want to change the device selection? (y/n)\n\n"; read validateChange;
if [ "${validateChange}" = "y" ]; then
echo -e "\n\n${brks}\nNetwork Interface\n${brks}";
echo -e "\nAvailable Interfaces:  $(ls /sys/class/net/ | tr '\n' ' ' | sort)";
echo -e "\n\nPlease enter the desired interface name...\n\n"; read nicName;
echo -e "\n\n${brks}\nStorage Device\n${brks}";
echo -e "\nAvailable Devices:  $(sar -dp | grep Average | awk '{print $2}' | tr '\n' ' ' | sort)";
echo -e "\n\nPlease enter the desired device name...\n\n"; read storageName;
echo -e "\n\n${brkm}\nValidation\n${brkm}";
echo -e "\nYou have made the following selection..."
echo -e "\n\tnicName=${nicName}\n\tstorageName=${storageName}";
echo -e "\n\nAre these values correct? (y/n)\n\n"; read validateChange;
if [ "${validateChange}" = "y" ]; then
echo -e "# Devices\nnicName=\"${nicName}\"\nstorageName=\"${storageName}\"" > ${perfDevices};
source ${perfDevices};
echo -e "\n\n${brkm}\nUpdated Configuration\n${brkm}"
echo -e "\n${brks}\nNetwork Interface\n${brks}\n";
grep nicName ${perfDevices}
echo -e "\n${brks}\nStorage Device\n${brks}\n";
grep storageName ${perfDevices}
${sourceDir}/perfMonitor.sh network
${sourceDir}/perfMonitor.sh storage
else echo -e "\n\nNo changes have been made.\n"; fi;
else echo -e "\n\nNo changes have been made.\n"; fi;
fi;

# Config - Statistics Collection - Enable
if [ "${viewEnable}" = "1" ]; then
echo -e "\n\n${brk}\nalgodMon - perfConfig - Statistics Collection - Enable\n${brk}";
echo -e "\n${brkm}\nConfiguration: 'sysstat' service\n${brkm}\n";
grep "^ENABLED=" /etc/default/sysstat;
echo -e "\n${brkm}\nConfirmation\n${brkm}\n";
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
echo -e "\n${brkm}\nConfirmation\n${brkm}\n";
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
