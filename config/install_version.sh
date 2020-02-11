#!/bin/bash
set -e
# You can also find (https://www.apache.org/dyn/closer.cgi) and manually update to use fastest mirror site when overflow traffic limit, such as 
# archive.apache.org/dist
# mirror.its.dal.ca/apache
# muug.ca/mirror/apache-dist
# apache_apache_root_site=archive.apache.org/dist 
done=0
while : ; do
  res=$(curl -s -L https://www.apache.org/dyn/closer.cgi|grep -B 1 'Other mirror sites'|grep -Eo '(http|https)://[^/"]+'|head -1)

  if [[ $res != *"apache"* ]]; then
    res=$res/apache                          #if url does not contains apache add at the end
  fi

  res2=$(wget --spider $res/hadoop -nv 2>&1) #check if hadoop link in mirror
  if [[ $res2 = *"OK"* ]]; then
    apache_root_site=$res
    echo "Found mirror $apache_root_site"
    break
  else
    continue
  fi
done

#software repository links
jdk_version=211
java_file_name=jdk-8u211-linux-x64.tar.gz
dl_link_java=https://files-cdn.liferay.com/mirrors/download.oracle.com/otn-pub/java/jdk/8u121-b13/jdk-8u121-linux-x64.tar.gz

file_name_hadoop=hadoop-2.7.7.tar.gz
dl_link_hadoop=${apache_root_site}/hadoop/common/hadoop-2.7.7/hadoop-2.7.7.tar.gz

file_name_tez=tez-0.9.1-bin.tar.gz
dl_link_tez=${apache_root_site}/tez/0.9.1/apache-tez-0.9.1-bin.tar.gz

file_name_hive=hive-1.2.2.tar.gz
dl_link_hive=${apache_root_site}/hive/hive-1.2.2/apache-hive-1.2.2-bin.tar.gz

file_name_hive2=hive-2.3.6.tar.gz
dl_link_hive2=${apache_root_site}/hive/hive-2.3.6/apache-hive-2.3.6-bin.tar.gz

#file_name_confluent=confluent-3.3.0.tar.gz
#dl_link_confluent=http://packages.confluent.io/archive/3.3/confluent-oss-3.3.0-2.11.tar.gz
file_name_confluent=confluent-4.1.1.tar.gz
dl_link_confluent=http://packages.confluent.io/archive/4.1/confluent-oss-4.1.1-2.11.tar.gz

file_name_flink=flink-1.5.0.tgz
#dl_link_flink=${apache_root_site}/flink/flink-1.5.0/flink-1.5.0-bin-hadoop27-scala_2.11.tgz
dl_link_flink=https://archive.apache.org/dist/flink/flink-1.5.0/flink-1.5.0-bin-hadoop27-scala_2.11.tgz

file_name_elastic=elastic-2.3.4.tar.gz
dl_link_elastic=https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch/2.3.4/elasticsearch-2.3.4.tar.gz

file_name_zeppelin=zeppelin-0.8.1.tgz
#dl_link_zeppelin=${apache_root_site}/zeppelin/zeppelin-0.7.3/zeppelin-0.7.3-bin-all.tgz
dl_link_zeppelin=${apache_root_site}/zeppelin/zeppelin-0.8.1/zeppelin-0.8.1-bin-all.tgz

file_name_grafana=grafana-5.1.3.tar.gz
dl_link_grafana=https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana-5.1.3.linux-x64.tar.gz 

file_name_spark=spark-2.3.4.tgz
dl_link_spark=${apache_root_site}/spark/spark-2.3.4/spark-2.3.4-bin-hadoop2.7.tgz

file_name_hbase=hbase-1.3.6.tar.gz
dl_link_hbase=${apache_root_site}/hbase/hbase-1.3.6/hbase-1.3.6-bin.tar.gz

file_name_phoenix=phoenix-4.14.3.tar.gz
dl_link_phoenix=${apache_root_site}/phoenix/apache-phoenix-4.14.3-HBase-1.3/bin/apache-phoenix-4.14.2-HBase-1.3-bin.tar.gz

file_name_livy=livy-0.5.0-incubating.zip
dl_link_livy=${apache_root_site}/incubator/livy/0.5.0-incubating/livy-0.5.0-incubating-bin.zip
