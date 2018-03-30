#!/bin/bash
set -e
#install flags
install_java=true #install oracle java 8

install_hadoop=true
install_hive=true #this is to install both hive 1 and 2. Default is hive 2

install_confluent=true
install_flink=true

install_spark=true
install_livy=false

install_grafana=true
install_zeppelin=true

install_hbase=true
install_phoenix=true

install_mongo=true
install_elastic=false