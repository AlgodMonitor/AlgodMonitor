-------------------------------------------------------------------------
Release Information
-------------------------------------------------------------------------
Name: algodMonitor

Version: 1.2

Copyright: 2021


-------------------------------------------------------------------------
Description
-------------------------------------------------------------------------

Suite of monitoring utilities for Algorand nodes.

Provides abiility to track key performance indicators over time.


-------------------------------------------------------------------------
Features
-------------------------------------------------------------------------

Generates reports showing the following data:
 - Node Synchronization
 - Node Errors
 - Storage Use
 - Network Peers
 - Network Errors
 - Consensus Participation
 - Participation Key Expiration
 - Token Balances
 - Token Supply
 - Token Online Stake


-------------------------------------------------------------------------
Installation
-------------------------------------------------------------------------
`git clone https://github.com/consiglieri-cfi/algodMonitor

chmod +x ./aglodMonitor/config.sh

./algodMonitor/config.sh`

 
-------------------------------------------------------------------------
Development Fund
-------------------------------------------------------------------------

Support development of 'algodMon' and earn NFT rewards!

Address: OBQIVIPTUXZENH2YH3C63RHOGS7SUGGQTNJ52JR6YFHEVFK5BR7BEYKQKI


-------------------------------------------------------------------------
Roadmap
-------------------------------------------------------------------------

Next release will include new features for archive nodes.

Significant enhancements are also in progress for the Network Monitor.

 - Network Error Monitor
 - Network Utilization Monitor
 - Error Monitor Improvements
 - Host Alert Function
 - Host Performance Monitor
 - Performance telemetry capture
 - Performance telemetry transmit
 - Participation Key Setup
 - Archive Node Features


-------------------------------------------------------------------------
Registration (via Discord)
-------------------------------------------------------------------------

Username: Consiglieri#4724

Link: https://discord.com/invite/nxrYwdxDSf


-------------------------------------------------------------------------
syncMonitor
-------------------------------------------------------------------------
- Node Synchronization Check
- Node Synchronization Report


-------------------------------------------------------------------------
networkMonitor
-------------------------------------------------------------------------
- Monitor connections on port '4160'
- Report hostnames of peers
- Count connections over time (7 days)


-------------------------------------------------------------------------
partkeyMonitor
-------------------------------------------------------------------------
- Report participation key expiration date 
- Generate time series report


-------------------------------------------------------------------------
voteMonitor
-------------------------------------------------------------------------
- Count your votes in participation
- Generate time series report
- Call 'errorMonitor'


-------------------------------------------------------------------------
errorMonitor
-------------------------------------------------------------------------
- Check 'node.log' for errors
- Check 'node.log' for warnings
- Generate output with diagnostic messages
- Rotate 'node.log'


-------------------------------------------------------------------------
tokenMonitor
-------------------------------------------------------------------------
- Monitor Supply
- Monitor Online Stake
- Monitor Wallet Balance


-------------------------------------------------------------------------
storageMonitor
-------------------------------------------------------------------------
- Monitor utilization of ./node
- Monitor utilization of database files
- Monitor utilization of log files
