#!/bin/bash
set -e

# Clean up data
echo "Cleaning up Kafka and Hadoop data Start"
rm -rf /mnt/kafka-logs/
rm -rf /mnt/zookeeper/
rm -rf /mnt/dfs/name/*
rm -rf /mnt/dfs/data/*
rm -rf /mnt/connect.offsets
rm -rf /mnt/logs/*
echo "Cleaning up Kafka and Hadoop data Complete"

echo "Formatting Hadoop NameNode Start"
hadoop namenode -format -force -nonInteractive > /dev/null 2>&1
echo "Formatting Hadoop NameNode Complete"

echo "Data Cleanup Process is Complete."


