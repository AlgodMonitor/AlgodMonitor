#!/bin/bash
#  Algod Monitor - v1.3 - Node Monitor - Configuration Utility
#
#  Donate/Register: INFRA6E4IZQJQGBU3KLB54GU5SY5SS32SHE2Q6ISCDUUZEZN6INUM64CRU
#
#  Copyright 2022 - Algod Monitor

# Initialization
sourceDir=$(dirname "$0");
configFile=${sourceDir}/../config/globalValues.cfg;
chmod +x $(find ${sourceDir}/../ -name "*.sh");
mkdir ${sourceDir}/../logs;
mkdir ${sourceDir}/../logs/nodeMessages;
mkdir ${sourceDir}/../logs/networkPeers;

# Banner
brk=$(printf '=%.0s' {1..120}); brkm=$(printf '=%.0s' {1..70}); brks=$(printf '=%.0s' {1..30});
echo -e "\n\n${brk}\nAlgod Monitor - v1.3 - Algorand Node Monitoring - Configuration\n${brk}\n";
echo -e "${brkm}\nWelcome!\n${brkm}\n";
echo -e "Thank you for using 'Algod Monitor' node monitoring solution!\n\nPlease share requests and feedback via Github:\n\n\thttps://github.com/consiglieri-cfi/algodMonitor/\n";
echo -e "\n${brks}\nDonate / Register\n${brks}\n";
echo -e "Support development of 'Algod Monitor' and earn NFT rewards!\n\n\tINFRA6E4IZQJQGBU3KLB54GU5SY5SS32SHE2Q6ISCDUUZEZN6INUM64CRU\n\n";
read -n 1 -s -r -p "Press any key to begin setup...";

# Existing Config
checkConf=$(grep "dataDir\|nodeDir" ${configFile} | wc -l);
if [ ${checkConf} -gt 0 ]; then
echo -e "\n\n\n\n\n${brkm}\nExisting Configuration Detected\n${brkm}\n"
echo -e "Existing configuration settings has been found.\n\nPlease review and confirm settings are correct.\n"
echo -e "\n\tPath: ${configFile}\n";
echo -e "\n${brks}\nValidation\n${brks}\n"; grep "# Data\|monitorDir\|dataDir\|nodeDir" ${configFile};
echo -e "\n\nAre the value shown correct? (y/n)\n\n"; read checkConf;
if [ ${checkConf} = "n" ]; then
echo -e "\n\n${brkm}\nClear Configuration\n${brkm}\n";
sed -i '/# Data\|dataDir=.*\|nodeDir=.*\|monitorDir=.*/d' ${configFile};
echo -e "Configuration has been cleared.\n\nPlease restart 'config.sh' to reconfigure Algod Monitor settings.\n\n";
kill -9 ${BASHPID}; fi;
else

# Monitor Directory
echo -e "\n\n${brkm}\nConfiguration - Algod Monitor Directory\n${brkm}";
echo -e "\nPlease specify the path to Algod Monitor directory...\n\nExample: ${HOME}/AlgodMonitor\n\n"; read monitorDir;
echo -e "\n\n${brks}\nValidation\n${brks}\n\nYou have entered: ${monitorDir}\n\n\nIs this value correct? (y/n)\n\n"; read checkPath;
if [ ! ${checkPath} = "y" ]; then
echo -e "\nPlease restart 'config.sh' to reconfigure Algod Monitor settings.\n"; kill ${BASHPID};
else
echo -e "\n\nProcessing:  Saving configuration..."
echo -e "# Data\nmonitorDir=${monitorDir}" >> ${configFile}; echo -e "\nDone.\n";
fi;

# Node Directory
echo -e "\n\n${brkm}\nConfiguration - Algorand Node Directory\n${brkm}";
echo -e "\nPlease specify the path to the Algorand Node directory...\n\nExample: ${HOME}/node\n\n"; read nodeDir;
echo -e "\n\n${brks}\nValidation\n${brks}\n\nYou have entered: ${nodeDir}\n\n\nIs this value correct? (y/n)\n\n"; read checkPath;
if [ ! ${checkPath} = "y" ]; then
echo -e "\nPlease restart 'config.sh' to reconfigure Algod Monitor settings.\n"; kill ${BASHPID};
else
echo -e "\n\nProcessing:  Saving configuration..."
echo -e "nodeDir=${nodeDir}" >> ${configFile}; echo -e "\nDone.\n";
fi;

# Data Directory
echo -e "\n\n${brkm}\nConfiguration - Algorand Data Directory\n${brkm}";
echo -e "\nPlease specify the path to the Algorand Data directory...\n\nExample: ${nodeDir}/data\n\n"; read dataDir;
echo -e "\n\n${brks}\nValidation\n${brks}\n\nYou have entered: ${dataDir}\n\n\nIs this value correct? (y/n)\n\n"; read checkPath;
if [ ! ${checkPath} = "y" ]; then
echo -e "\nPlease restart configuration and re-enter the settings.\n"; kill ${BASHPID};
else
echo -e "\n\nProcessing:  Saving configuration..."
echo -e "dataDir=${dataDir}" >> ${configFile}; echo -e "\nDone.\n";
fi;

# Configuration
echo -e "\n\n\n${brkm}\nConfiguration Review\n${brkm}\n"
echo -e "Please review the current configuration file.\n\n\nPath: ${monitorDir}/config/globalValues.cfg\n";
echo -e "\n${brks}\nValidate Settings\n${brks}\n"; grep "# Data\|monitorDir\|dataDir\|nodeDir" ${configFile};
echo -e "\n\nAre the values shown correct? (y/n)\n\n"; read checkConf;
if [ ! ${checkConf} = "y" ]; then
echo -e "\n\n${brkm}\nClear Configuration\n${brkm}\n";
sed -i '/\# Data\|dataDir=.*\|nodeDir=.*\|monitorDir=.*/d' ${configFile};
echo -e "Configuration has been cleared.\n\nPlease restart 'config.sh' to reconfigure Algod Monitor settings.\n\n";
kill ${BASHPID};
else
source ${configFile}
fi;
fi;

# Complete
echo -e "\n\n\n${brkm}\nConfiguration Complete\n${brkm}";
echo -e "\n${brks}\nManual Execution\n${brks}\n";
echo -e "Configuration has completed successfully.\n\nExecute 'batch-monitor' to validate functionality:\n\n\t${monitorDir}/batch-monitor.sh\n";
echo -e "\n${brks}\nSchedule Execution\n${brks}\n";
echo -e "Run 'crontab -e' to edit local system scheduler configuration.\n\nAdd the following entry for hourly exection:\n\n0 */1 * * * ${monitorDir}/batch-monitor.sh\n\n";

# EOF
