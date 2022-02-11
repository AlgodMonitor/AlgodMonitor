#!/bin/bash
# Algod Monitor - Token Monitor - Distribution / Balance Report

# Set Variables
assetID=590620260
indexerAddress=https://algoindexer.algoexplorerapi.io
outDir=/home/ac0/ares

# Date
currentDate=$(date +%Y-%m-%d);
currentSecond=$(date +%H:%M:%S);
currentEpoch=$(date +%s);
currentFilename=$(date +%Y-%m-%d-%Hh_%Mm_%Ss)
currentTime=$(echo -e "${currentDate}  ${currentSecond}");

# Format
brk=$(printf '=%.0s' {1..120});
brkm=$(printf '=%.0s' {1..70});
brks=$(printf '=%.0s' {1..30});

# Make Data Directories
dataDir=${outDir}/hist-balances
acctDir=${outDir}/hist-reports
holdDir=${outDir}/hist-holders
rprtDir=${outDir}/holding-reports
mkdir -p ${dataDir} ${acctDir} ${holdDir}/epoch ${rprtDir} 2>/dev/null

# Banner
echo -e "\n\n${brk}\nAlgod Monitor - Token Monitor - ASA Balance Monitor\n${brk}";

# Get Balances
echo -e "\n${brks}\nGet Statistics\n${brks}";
echo -e "\nChecking balances for ASA ${assetID}...\n";
curl -s ${indexerAddress}/v2/assets/${assetID}/balances > ${dataDir}/balances-${currentEpoch};
exitStatus=${?};
if [ ${exitStatus} -gt 0 ]; then
 echo -e "\n\tERROR: API CALL FAILED - STATUS ${exitStatus}\n\n\tCHECK INTERNET CONNECTION / API HOST\n";
 exit
else
 echo -e "Done! HTTP Status ${exitStatus}";
fi

# Parse Balances
echo -e "\n\n${brks}\nParsing Balances\n${brks}";
echo -e "\nWriting output file...\n";
sed -E 's/\{\"address/\n&/g' ${dataDir}/balances-${currentEpoch} | tr -d '{\"' | awk -F, '{print $1, $2}' | sed '1d' | sed 's/:/: /g' > ${dataDir}/balances-${currentEpoch}-parsed
echo -e "Done!"

# Log Holder Accounts
echo -e "\n\n${brks}\nListing Accounts\n${brks}";
echo -e "\nWriting output file...";
awk '{print $2}' ${dataDir}/balances-${currentEpoch}-parsed > ${holdDir}/epoch/holders-${currentEpoch}
echo -e "Writing new account list...\n"
cat ${holdDir}/account_list ${holdDir}/epoch/holders-${currentEpoch} 2>/dev/null | sort -u > ${holdDir}/account_list-new
echo -e "Done!"
echo -e "\nPrevious Holders: $(wc -l ${holdDir}/account_list 2>/dev/null | awk '{print $1}')"
echo -e "Current Holders: $(wc -l ${holdDir}/epoch/holders-${currentEpoch} | awk '{print $1}')"
mv ${holdDir}/account_list-new ${holdDir}/account_list

# Write Balance Report
echo -e "\n\n${brks}\nWriting Reports\n${brks}\n";
while read address; do
 echo -e "Processing: ${address}";
 # Make Account Directory
 if [ ! -d ${acctDir}/${address} ]; then
  mkdir ${acctDir}/${address}
 fi;
 # Check Balance
 balanceCurrent=$(grep ${address} ${dataDir}/balances-${currentEpoch}-parsed | awk '{print $NF}')
 # Check Generic Value - Previous Balance
 if [ ! -f ${acctDir}/${address}/balance-previous ]; then
  echo "balancePrevious=0" > ${acctDir}/${address}/balance-previous
 fi;
 # Check Generic Value - ATH Balance
 if [ ! -f ${acctDir}/${address}/balance-ATH ]; then
  echo "balanceATH=0" > ${acctDir}/${address}/balance-ATH
 fi;
 # Source Values
 source ${acctDir}/${address}/balance-previous
 source ${acctDir}/${address}/balance-ATH
 # Calculate Change
 deltaPrevious=$(echo "${balanceCurrent} - ${balancePrevious}" | bc -l)
 deltaATH=$(echo "${balanceCurrent} - ${balanceATH}" | bc -l)
 # Print Values - Debug
 # echo -e "\nCurrent: ${balanceCurrent}\nATH: ${balanceATH}\nPrev: ${balancePrevious}\nDelta Prev: ${deltaPrevious}\nDelta ATH: ${deltaATH}\n"
 # Report Delta
 if [[ ${balanceCurrent} -gt ${balancePrevious} ]]; then
  echo -e "${currentTime} \t ${address} \t ${balanceCurrent} \t ${balancePrevious} \t ${deltaPrevious} \t ${deltaATH}" >> ${rprtDir}/${currentFilename}-balance_increase
 elif [[ ${balanceCurrent} -lt ${balancePrevious} ]]; then
  echo -e "${currentTime} \t ${address} \t ${balanceCurrent} \t ${balancePrevious} \t ${deltaPrevious} \t ${deltaATH}" >> ${rprtDir}/${currentFilename}-balance_decrease
 elif [[ ${balanceCurrent} -eq ${balancePrevious} ]]; then
  echo -e "${currentTime} \t ${address} \t ${balanceCurrent} \t ${balancePrevious} \t ${deltaPrevious} \t ${deltaATH}" >> ${rprtDir}/${currentFilename}-balance_equal
 fi;
 # Report Time Series
 echo -e "${currentTime} \t ${address} \t ${balanceCurrent} \t  ${balancePrevious} \t ${deltaPrevious} \t ${deltaATH}" >> ${acctDir}/${address}/report
 # Update Balance
 echo -e "balancePrevious=${balanceCurrent}" > ${acctDir}/${address}/balance-previous
 # Update ATH
 if [[ ${balanceCurrent} -gt ${balanceATH} ]]; then
  echo -e "balanceATH=${balanceCurrent}" > ${acctDir}/${address}/balance-ATH
  echo -e "${currentTime} \t ${address} \t ${currentBalance} \t ${balancePrevious} \t ${deltaPrevious} \t ${deltaATH}" >> ${rprtDir}/${currentFilename}-balance_ATH
 fi;
done < ${holdDir}/account_list

echo -e "\nDone!\n"


echo -e "\n${brks}\nSummary\n${brks}\n";
wc -l ${rprtDir}/${currentFilename}-balance* | grep -v "total"
echo -e "\nDone!\n"
