#!/bin/bash
set -e

# Shutdown Hadoop
if [ -h /opt/hadoop ]; then
    echo "Shutting down Hadoop"
    hadoop-daemon.sh stop datanode
    hadoop-daemon.sh stop namenode
fi

# Shutdown Hive Metastore and ElasticSearch
echo "Shutting down all other Java process, Hive Meta, ElasticSearch"
killall java






