-------------------------------------------------------------------------
Release Information
-------------------------------------------------------------------------
Name: Algod Monitor

Version: 1.3

Copyright: 2022


-------------------------------------------------------------------------
Description
-------------------------------------------------------------------------

Suite of monitoring utilities for Algorand nodes.

Track system health, event data, and key performance indicators over time.


-------------------------------------------------------------------------
Features
-------------------------------------------------------------------------

An overview of features is provided on the following page:

https://algod.network/algod-monitor-features-for-participation-nodes-224351877314


Algod Monitor generates reports with the following data:

 - Node Synchronization
 - Node Errors
 - Storage Use
 - Network Peers
 - Network Errors
 - Consensus Participation
 - Participation Key Expiration
 - Performance (CPU, MEM, Disk IO, Network)
 - Token Balances
 - Token Supply
 - Token Online Stake


-------------------------------------------------------------------------
Installation
-------------------------------------------------------------------------
`git clone https://github.com/AlgodMonitor/AlgodMonitor`

`chmod +x ./AlgodMonitor/config/config.sh`

`./AlgodMonitor/config/config.sh`


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
Development Fund
-------------------------------------------------------------------------

Support the AlgodMonitor development fund:

INFRA6E4IZQJQGBU3KLB54GU5SY5SS32SHE2Q6ISCDUUZEZN6INUM64CRU


-------------------------------------------------------------------------
Feedback / Support 
-------------------------------------------------------------------------

Provide feedback or contribute to AlgodMonitor and receive limited edition NFTs!

Discord Username: AlgodMonitor#4724

Discord Link: https://discord.gg/EV3MX7wGtg

Twitter: https://twitter.com/algodmonitor


-------------------------------------------------------------------------
Sync Monitor
-------------------------------------------------------------------------
- Node Synchronization Check
- Node Synchronization Report


-------------------------------------------------------------------------
Network Monitor
-------------------------------------------------------------------------
- Monitor connections on port '4160'
- Report hostnames of peers
- Count connections over time (7 days)


-------------------------------------------------------------------------
Participation Key Monitor
-------------------------------------------------------------------------
- Report participation key expiration date 
- Generate time series report


-------------------------------------------------------------------------
Vote Monitor
-------------------------------------------------------------------------
- Count your votes in participation
- Generate time series report
- Call 'errorMonitor'


-------------------------------------------------------------------------
Error Monitor
-------------------------------------------------------------------------
- Check 'node.log' for errors
- Check 'node.log' for warnings
- Generate output with diagnostic messages
- Rotate 'node.log'


-------------------------------------------------------------------------
Performance Monitor
-------------------------------------------------------------------------
- Enable / disable performance monitoring
- Check daily averages
- Check historical data
- Generate telemetry reports


-------------------------------------------------------------------------
Token Monitor
-------------------------------------------------------------------------
- Monitor Supply
- Monitor Online Stake
- Monitor Wallet Balance


-------------------------------------------------------------------------
Storage Monitor
-------------------------------------------------------------------------
- Monitor utilization of ./node
- Monitor utilization of database files
- Monitor utilization of log files

