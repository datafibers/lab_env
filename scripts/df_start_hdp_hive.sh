#!/bin/bash
set -e

# Starting Hadoop
if [ -h /opt/hadoop ]; then
    echo "Starting Hadoop. Make sure you format HDP using init_all.sh if any error happens"
    hadoop-daemon.sh start namenode
    hadoop-daemon.sh start datanode
fi
echo "Hadoop is started"
# Starting Hive Metastore and server2
if [ -h /opt/hive ]; then
    echo "Starting Hive Metastore"
    hive --service metastore 1>> /mnt/logs/metastore.log 2>> /mnt/logs/metastore.log &
	echo "Starting Hive Server2"
    hive --service hiveserver2 1>> /mnt/logs/hiveserver2.log 2>> /mnt/logs/hiveserver2.log &
fi

echo "Hive is started"

