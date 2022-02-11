#!/bin/bash
# Algod Monitor - Token Monitor - Report Viewer

# Format
brk=$(printf '=%.0s' {1..120});
brkm=$(printf '=%.0s' {1..70});
brks=$(printf '=%.0s' {1..30});

# Variables
dataDir=/home/ac0/ares

# Component Variables
for viewComponent in viewSummary viewReport; do export ${viewComponent}=0; done
componentName=$1

# Component Selector
if [ "${componentName}" = "summary" ]; then
viewSummary=1;
elif [ "${componentName}" = "account" ]; then
viewReport=1;
else
echo -e "\n\n${brk}\nAlgod Monitor - Token Monitor - ASA Balance Monitor\n${brk}\n";
echo -e "Display 'Algod Monitor' ASA Balance reports on screen.\n\nPlease specify a component when running the 'View Report' command.\n";
echo -e "\nExample:\n\t ./view-report.sh summary \n\t ./view-report.sh account \n";
echo -e "\nOptions:\n\t summary \n\t account \n";
echo -e "\nEnter a component name...\n"; read componentName;
echo -e "\n\n\nDisplaying ${componentName} report...\n\n";
${dataDir}/view-report.sh ${componentName};
fi;

# Redirect - Summary
if [ "${viewSummary}" = "1" ]; then
echo -e "\n${brkm}\nReport Viewer - Recent Summary Reports\n${brkm}\n";
ls -1 ${dataDir}/holding-reports/ | tail -6
echo -e "\n\nEnter the file name...\n";
read filePath;
echo -e "\n"
echo -e "\nDate Time Account BalanceCurrent BalancePrevious DeltaPrevious DeltaATH\n$(cat ${dataDir}/holding-reports/${filePath})" | column -t
fi;

# Redirect - Account
if [ "${viewReport}" = "1" ]; then
echo -e "\n${brkm}\nReport Viewer - Account Balance Reports\n${brkm}\n";
echo -e "Display the full list of accounts, or search for an account?\n\nOptions:\n\t full\n\t search\n"
read acctSpec
if [ ${acctSpec} = full ]; then
 echo -e "\n\n${brks}\nFull List\n${brks}\n";
 cat ${dataDir}/hist-holders/account_list
 elif [ ${acctSpec} = search ]; then
 echo -e "\nEnter search string (e.g. ABC5)\n";
 read searchString;
 echo -e "\n${brks}\nSearch Results\n${brks}\n";
 grep ${searchString} ${dataDir}/hist-holders/account_list;
 else
 ${dataDir}/view-report.sh ${componentName};
fi
echo -e "\n\nEnter the account name...\n";
read acctName;
echo -e "\n\n${brkm}\nBalance History\n${brkm}\n"
echo -e "\nDate Time Account BalanceCurrent BalancePrevious DeltaPrevious DeltaATH\n$(cat ${dataDir}/hist-reports/${acctName}/report)" | column -t
fi;
