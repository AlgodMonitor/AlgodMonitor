#!/bin/bash
#
#  algodMon v1.2 - batchMonitor - Monitor Scheduling Agent
#
#  Copyright 2021 - Consiglieri-cfi
#

sourceDir=$(dirname "$0");
${sourceDir}/network-monitor/network-monitor.sh
${sourceDir}/partkey-monitor/partkey-monitor.sh
${sourceDir}/storage-monitor/storage-monitor.sh
${sourceDir}/token-monitor/token-monitor.sh
${sourceDir}/sync-monitor/sync-monitor.sh
${sourceDir}/vote-monitor/vote-monitor.sh
