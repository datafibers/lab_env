#!/bin/bash
set -e

#software repository links
dl_link_java=http://download.oracle.com/otn-pub/java/jdk/8u161-b12/2f38c3b165be4555a1fa6e98c45e0808/jdk-8u161-linux-x64.tar.gz

file_name_hadoop=hadoop-2.7.3.tar.gz
dl_link_hadoop=https://archive.apache.org/dist/hadoop/common/hadoop-2.7.3/hadoop-2.7.3.tar.gz

file_name_hive=hive-1.2.1.tar.gz
dl_link_hive=https://archive.apache.org/dist/hive/hive-1.2.1/apache-hive-1.2.1-bin.tar.gz

file_name_hive2=hive-2.3.2.tar.gz
dl_link_hive2=https://archive.apache.org/dist/hive/hive-2.3.2/apache-hive-2.3.2-bin.tar.gz

file_name_confluent=confluent-3.3.0.tar.gz
dl_link_confluent=http://packages.confluent.io/archive/3.3/confluent-oss-3.3.0-2.11.tar.gz

file_name_flink=flink-1.3.2.tgz
dl_link_flink=http://www-us.apache.org/dist/flink/flink-1.3.2/flink-1.3.2-bin-hadoop26-scala_2.11.tgz

file_name_elastic=elastic-2.3.4.tar.gz
dl_link_elastic=https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch/2.3.4/elasticsearch-2.3.4.tar.gz

file_name_zeppelin=zeppelin-0.7.3.tgz
dl_link_zeppelin=https://archive.apache.org/dist/zeppelin/zeppelin-0.7.3/zeppelin-0.7.3-bin-all.tgz

file_name_grafana=grafana-5.0.3.tar.gz
dl_link_grafana=https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana-5.0.3.linux-x64.tar.gz

file_name_spark=spark-2.2.0.tgz
dl_link_spark=https://archive.apache.org/dist/spark/spark-2.2.0/spark-2.2.0-bin-hadoop2.7.tgz

file_name_hbase=hbase-1.1.2.tar.gz
dl_link_hbase=https://archive.apache.org/dist/hbase/1.1.2/hbase-1.1.2-bin.tar.gz

file_name_phoenix=phoenix-4.13.1.tar.gz
dl_link_phoenix=http://archive.apache.org/dist/phoenix/apache-phoenix-4.13.1-HBase-1.1/bin/apache-phoenix-4.13.1-HBase-1.1-bin.tar.gz

file_name_livy=livy-0.4.0.tar.gz
dl_link_livy=https://github.com/datafibers-community/df_demo/releases/download/livy/livy-0.4.0-incubating-bin.tar.gz