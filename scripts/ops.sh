#!/bin/bash
#set -e #comment this since the curl returns none-zero when service is not available

#######################################################################################################
# Description : This script is used for df service operations, such as start, stop, and query status
#######################################################################################################

usage () {
    printf "Usage:\n"
        printf " ops [service operation] [service name] [service option]\n"
        printf " ops [admin operation] [admin option]\n"
        printf "\n"
        printf "Parameters:\n"
        printf "[service operation]\n"
        printf "%-25s: %-50s\n" "start|stop|restart" "Perform start|stop|restart on df environment and service"
    printf "\n"
        printf "[service]\n"
        printf "%-25s: %-50s\n" "default" "Run hadoop／hive, zeppelin. This is the default option."
        printf "%-25s: %-50s\n" "all" "Run hadoop/hive, zeppelin, spark, flink, hbase, kafka."
	printf "%-25s: %-50s\n" "hive" "Run hadoop/hive."
        printf "%-25s: %-50s\n" "spark" "Run hadoop/hive, zeppelin, spark"
        printf "%-25s: %-50s\n" "flink" "Run hadoop/hive, zeppelin, flink"
        printf "%-25s: %-50s\n" "hbase" "Run hadoop/hive, zeppelin, hbase"
        printf "%-25s: %-50s\n" "kafka" "Run hadoop/hive, zeppelin, kafka"
    printf "\n"
    printf "[admin operation]\n"
        printf "%-25s: %-50s\n" "status" "Check status of data service and environment"
        printf "%-25s: %-50s\n" "format" "Format all data and logs"
        printf "%-25s: %-50s\n" "help" "Show this help"
    printf "\n"
        printf "Examples:\n"
        printf "%-25s: %-50s\n" "ops start" "Run default environment, hadoop/hive and zeppelin"
        printf "%-25s: %-50s\n" "ops start hbase" "Run default environment and hbase"
        printf "%-25s: %-50s\n" "ops restart spark" "Restart default environment and spark"
        printf "%-25s: %-50s\n" "ops stop" "Stop all default services"
        printf "%-25s: %-50s\n" "ops stop hbase" "Stop all default services and hbase"       
        printf "%-25s: %-50s\n" "ops status" "Check running status for all df and its related services"
        printf "%-25s: %-50s\n" "ops format" "Format environment data and logs"
    printf "\n"
    exit
}

if [ "$#" -ne 1 ] && [ "$#" -ne 2 ] ; then
    usage
fi

action=${1}
service=${2:-default}

DF_APP_MNT=/mnt
DF_APP_DEP=/opt
DF_APP_HDFS=/app
DF_APP_CONFIG=${DF_APP_MNT}/etc
DF_APP_LOG=${DF_APP_MNT}/logs
DF_APP_LIB=$DF_APP_DEP/lib

KAFKA_DAEMON_NAME=SupportedKafka
KAFKA_CONNECT_DAEMON_NAME=connectdistributed
ZOO_KEEPER_DAEMON_NAME=QuorumPeerMain
SCHEMA_REGISTRY_DAEMON_NAME=schemaregistrymain
FLINK_JM_DAEMON_NAME=JobManager
FLINK_TM_DAEMON_NAME=TaskManager
ZEPPELIN_DAEMON_NAME=ZeppelinServer
HBASE_HMASTER_DAEMON_NAME=HMaster
HBASE_RSERVER_DAEMON_NAME=HRegionServer
SPARK_JM_DAEMON_NAME=spark.deploy.master
SPARK_TM_DAEMON_NAME=spark.deploy.worker
HADOOP_NN_DAEMON_NAME=NameNode
HADOOP_DN_DAEMON_NAME=DataNode
YARN_RM_DAEMON_NAME=ResourceManager
YARN_NM_DAEMON_NAME=NodeManager
HIVE_SERVER_DAEMON_NAME=hive/.*HiveServer2
HIVE_METADATA_NAME=hive/.*HiveMetaStore
HIVE2_SERVER_DAEMON_NAME=hive2/.*HiveServer2
HIVE2_METADATA_NAME=hive2/.*HiveMetaStore

echo "****************Starting Operations****************"

format_all () {
rm -rf ${DF_APP_MNT}/kafka-logs/
rm -rf ${DF_APP_MNT}/zookeeper/
rm -rf ${DF_APP_MNT}/dfs/name/*
rm -rf ${DF_APP_MNT}/dfs/data/*
rm -rf ${DF_APP_MNT}/connect.offsets
rm -rf ${DF_APP_LOG}/*
echo "Formatted all data & logs"
hadoop namenode -format -force -nonInteractive > /dev/null 2>&1
echo "Formatted hadoop"
}

start_confluent () {
if [ -h ${DF_APP_DEP}/confluent ]; then
	sid=$(getSID ${KAFKA_DAEMON_NAME})
	if [ -z "${sid}" ]; then
		kafka-server-start ${DF_APP_CONFIG}/server.properties 1> ${DF_APP_LOG}/kafka.log 2> ${DF_APP_LOG}/kafka.log &
		sleep 3
	else
		echo "[WARN] Found Kafka daemon running. Please [stop] or [restart] it."
	fi
	echo "[INFO] Started [Apache Kafka Server]"

	sid=$(getSID ${SCHEMA_REGISTRY_DAEMON_NAME})
	if [ -z "${sid}" ]; then
		schema-registry-start ${DF_APP_CONFIG}/schema-registry.properties 1> ${DF_APP_LOG}/schema-registry.log 2> ${DF_APP_LOG}/schema-registry.log &
		sleep 5
	else
		echo "[WARN] Found Schema Registry daemon running. Please [stop] or [restart] it."
	fi
	echo "[INFO] Started [Schema Registry]"
	
	for jar in ${DF_APP_LIB}/*dependencies.jar; do
	  CLASSPATH=${CLASSPATH}:${jar}
	done
	export CLASSPATH

	sid=$(getSID ${KAFKA_CONNECT_DAEMON_NAME})
	if [ -z "${sid}" ]; then
		connect-distributed ${DF_APP_CONFIG}/connect-avro-distributed.properties 1> ${DF_APP_LOG}/distributedkafkaconnect.log 2> ${DF_APP_LOG}/distributedkafkaconnect.log &
		sleep 3
	else
		echo "[WARN] Found Kafka Connect daemon running. Please [stop] or [restart] it."
	fi

	echo "[INFO] Started [Apache Kafka Connect]"
else
	echo "[WARN] Confluent Platform Not Found"
fi
}

stop_confluent () {
if [ -h ${DF_APP_DEP}/confluent ]; then
	echo "[INFO] Shutdown [Schema Registry]"
	schema-registry-stop ${DF_APP_CONFIG}/schema-registry.properties 1> ${DF_APP_LOG}/schema-registry.log 2> ${DF_APP_LOG}/schema-registry.log &
	echo "[INFO] Shutdown [Apache Kafka Server]"
	kafka-server-stop ${DF_APP_CONFIG}/server.properties 1> ${DF_APP_LOG}/kafka.log 2> ${DF_APP_LOG}/kafka.log &
	sleep 15
	sid=$(getSID ${KAFKA_DAEMON_NAME})
	if [ ! -z "${sid}" ]; then
    	kill -9 ${sid}
		echo "[WARN] Kafka PID is killed after 15 sec. time out."
    fi
	echo "[INFO] Shutdown [Apache Kafka Connect]"
    sid=$(getSID ${KAFKA_CONNECT_DAEMON_NAME})
	if [ ! -z "${sid}" ]; then
    	kill -9 ${sid}
    fi
else
	echo "[WARN] Confluent Not Found"
fi
}

start_flink () {
if [ -h ${DF_APP_DEP}/flink ]; then
	sid=$(getSID ${FLINK_JM_DAEMON_NAME})
	sid2=$(getSID ${FLINK_TM_DAEMON_NAME})
	if [ -z "${sid}" ] && [ -z "${sid2}" ]; then
		start-cluster.sh 1 > /dev/null 2 > /dev/null
		echo "[INFO] Started [Apache Flink]"
		sleep 5
	else
		echo "[WARN] Found Flink daemon running. Please [stop] or [restart]."
	fi
else
	echo "[WARN] Apache Flink Not Found"
fi
}

stop_flink () {
if [ -h ${DF_APP_DEP}/flink ]; then
	stop-cluster.sh 1 > /dev/null 2 > /dev/null
	echo "[INFO] Shutdown [Apache Flink]"
	sleep 3
else
	echo "[WARN] Apache Flink Not Found"
fi
}

start_spark () {
if [ -h ${DF_APP_DEP}/spark ]; then
	sid=$(getSID ${SPARK_JM_DAEMON_NAME})
	sid2=$(getSID ${SPARK_TM_DAEMON_NAME})
	if [ -z "${sid}" ] && [ -z "${sid2}" ]; then
		start-all.sh 1 > /dev/null 2 > /dev/null
		echo "[INFO] Started [Apache Spark]"
		sleep 5
	else
		echo "[WARN] Found Spark daemon running. Please [stop] or [restart]."
	fi
else
	echo "[WARN] Apache Spark Not Found"
fi
}

stop_spark () {
if [ -h ${DF_APP_DEP}/spark ]; then
	stop-all.sh 1 > /dev/null 2 > /dev/null
	echo "[INFO] Shutdown [Apache Spark]"
	sleep 3
else
	echo "[WARN] Apache Spark Not Found"
fi
}

start_zeppelin () {
if [ -h ${DF_APP_DEP}/zeppelin ]; then
	sid=$(getSID ${ZEPPELIN_DAEMON_NAME})
	if [ -z "${sid}" ] ; then
		zeppelin-daemon.sh start 1 > /dev/null 2 > /dev/null
		echo "[INFO] Started [Apache Zeppelin]"
		sleep 5
	else
		echo "[WARN] Found Zeppelin daemon running. Please [stop] or [restart]."
	fi
else
	echo "[WARN] Apache Zeppelin Not Found"
fi
}

stop_zeppelin () {
if [ -h ${DF_APP_DEP}/zeppelin ]; then
	zeppelin-daemon.sh stop 1 > /dev/null 2 > /dev/null
	echo "[INFO] Shutdown [Apache Zeppelin]"
	sleep 3
else
	echo "[WARN] Apache Zeppelin Not Found"
fi
}

start_zookeeper () {
if [ -h ${DF_APP_DEP}/confluent ]; then
	sid=$(getSID ${ZOO_KEEPER_DAEMON_NAME})
	if [ -z "${sid}" ] ; then
	    zookeeper-server-start ${DF_APP_CONFIG}/zookeeper.properties 1> ${DF_APP_LOG}/zk.log 2>${DF_APP_LOG}/zk.log &
		echo "[INFO] Started [Apache Zookeeper]"
		sleep 5
	else
		echo "[WARN] Found Zookeeper daemon running. Please [stop] or [restart]."
	fi
else
	echo "[WARN] Apache Zookeeper Not Found"
fi
}

stop_zookeeper () {
if [ -h ${DF_APP_DEP}/confluent ]; then
	zookeeper-server-stop ${DF_APP_CONFIG}/zookeeper.properties 1> ${DF_APP_LOG}/zk.log 2> ${DF_APP_LOG}/zk.log &
	echo "[INFO] Shutdown [Apache Zookeeper]"
	sleep 3
else
	echo "[WARN] Apache Zookeeper Not Found"
fi
}

start_hbase () {
if [ -h ${DF_APP_DEP}/hbase ]; then
	sid=$(getSID ${HBASE_HMASTER_DAEMON_NAME})
	sid2=$(getSID ${HBASE_RSERVER_DAEMON_NAME})
	if [ -z "${sid}" ] && [ -z "${sid2}" ]; then
		start-hbase.sh
		echo "[INFO] Started [Apache HBase]"
		sleep 5
	else
		echo "[WARN] Found HBase daemon running. Please [stop] or [restart]."
	fi
else
	echo "[WARN] Apache HBase Not Found"
fi
}

stop_hbase () {
if [ -h ${DF_APP_DEP}/hbase ]; then
	stop-hbase.sh
	echo "[INFO] Shutdown [Apache HBase]"
	sleep 3
else
	echo "[WARN] Apache HBase Not Found"
fi
}

start_hadoop () {
if [ -h ${DF_APP_DEP}/hadoop ]; then
	sid=$(getSID ${HADOOP_NN_DAEMON_NAME})
	sid2=$(getSID ${HADOOP_DN_DAEMON_NAME})
	if [ -z "${sid}" ] && [ -z "${sid2}" ]; then
		start-dfs.sh
		start-yarn.sh
		echo "[INFO] Started [Apache Hadoop]"
		sleep 3
	else
		echo "[WARN] Found Hadoop daemon running. Please [stop] or [restart] it."
	fi
else
	echo "[WARN] Apache Hadoop Not Found"
fi

if [ -h ${DF_APP_DEP}/tez ]; then
	TEZ_DIR=$DF_APP_HDFS/tez/share
	hdfs dfs -test -d $TEZ_DIR
	if [ $? != 0 ]; then
		echo "[INFO] No Tez folder found, create it..."
		sleep 5
		hdfs dfs -mkdir -p $TEZ_DIR
		hdfs dfs -put ${DF_APP_DEP}/tez/share/tez.tar.gz $TEZ_DIR/
		echo "[INFO] Copied TEZ Lib to HDFS"
	fi
else
	echo "[WARN] Apache TEZ Not Found"
fi

if [ -h ${DF_APP_DEP}/hive ]; then
	${DF_APP_DEP}/hive/bin/hive --service metastore 1>> ${DF_APP_LOG}/metastore.log 2>> ${DF_APP_LOG}/metastore.log &
	echo "[INFO] Started [Apache Hive Metastore]"
	${DF_APP_DEP}/hive/bin/hive --service hiveserver2 1>> ${DF_APP_LOG}/hiveserver2.log 2>> ${DF_APP_LOG}/hiveserver2.log &
	echo "[INFO] Started [Apache Hive Server2]"
	sleep 3
else
	echo "[WARN] Apache Hive Not Found"
fi
if [ -h ${DF_APP_DEP}/hive2 ]; then
	${DF_APP_DEP}/hive2/bin/hive --service metastore 1>> ${DF_APP_LOG}/metastore_h2.log 2>> ${DF_APP_LOG}/metastore_h2.log &
	echo "[INFO] Started [Apache Hive2 Metastore]"
	${DF_APP_DEP}/hive2/bin/hive --service hiveserver2 1>> ${DF_APP_LOG}/hiveserver2_h2.log 2>> ${DF_APP_LOG}/hiveserver2_h2.log &
	echo "[INFO] Started [Apache Hive2 Server2]"
	sleep 3
else
	echo "[WARN] Apache Hive2 Not Found"
fi
}

stop_hadoop () {
echo "[INFO] Shutdown [Apache Hadoop]"
stop-yarn.sh
stop-dfs.sh
sid=$(getSID ${HIVE_METADATA_NAME})
kill -9 ${sid} 2> /dev/null
echo "[INFO] Shutdown [Apache Hive MetaStore]"
sleep 2
sid=$(getSID ${HIVE2_METADATA_NAME})
kill -9 ${sid} 2> /dev/null
echo "[INFO] Shutdown [Apache Hive2 MetaStore]"
sleep 2
sid=$(getSID ${HIVE_SERVER_DAEMON_NAME})
kill -9 ${sid} 2> /dev/null
echo "[INFO] Shutdown [Apache Hive Server2]"
sleep 2
sid=$(getSID ${HIVE2_SERVER_DAEMON_NAME})
kill -9 ${sid} 2> /dev/null
echo "[INFO] Shutdown [Apache Hive2 Server2]"
}

getSID() {
local ps_name=$1
local sid=$(ps -ef|grep -i ${ps_name}|grep -v grep|sed 's/\s\+/ /g'|cut -d " " -f2|head -1)
echo $sid
}

status () {
local service_name=$1
local service_name_show=$2
local critical=$3
sid=$(getSID $service_name)
if [ ! -z "${sid}" ]; then
	printf "%-8s %-20s %-50s\n" "[INFO]"  "[$service_name_show]" "is running at [${sid}]"
fi
if [ -z "${sid}" ] && [ ! -z "${critical}" ]; then
	printf "%-8s %-20s %-50s\n" "[ERROR]" "[$service_name_show]" "is missing and mandatory !"
fi
}

start_all_service () {
if [ "${service}" = "kafka" ]; then
	start_hadoop
	start_zookeeper
	start_confluent
	start_zeppelin
elif [ "${service}" = "all" ]; then
	start_hadoop
	start_zookeeper
	start_confluent
	start_hbase
	start_flink
	start_spark
	start_zeppelin
elif [ "${service}" = "default" ]; then
	start_hadoop
	start_zeppelin
elif [ "${service}" = "hive" ]; then
	start_hadoop	
elif [ "${service}" = "spark" ]; then
	start_hadoop
	start_spark
	start_zeppelin
elif [ "${service}" = "flink" ]; then
	start_hadoop
	start_flink
	start_zeppelin	
elif [ "${service}" = "hbase" ]; then
	start_hadoop
	start_zookeeper
	start_hbase
	start_zeppelin	
elif [ "${service:0:4}" = "mask" ]; then

	if [ "${service:4:1}" == "1" ]; then
	    start_hadoop
	fi
	if [ "${service:5:1}" == "1" ]; then
	    start_zeppelin
	fi	
	if [ "${service:6:1}" == "1" ]; then
	    start_confluent
	fi
	if [ "${service:7:1}" == "1" ]; then
	    start_flink
	fi
	if [ "${service:8:1}" == "1" ]; then
	    start_spark
	fi
	if [ "${service:9:1}" == "1" ]; then
	    start_hbase
	fi
	if [ "${service:10:1}" == "1" ]; then
	    start_zookeeper
	fi

	if [ "${service}" = "mask" ]; then
	    echo "[ERROR] No proper mask is specified."
	    echo "[INFO] Labops start masking setting uses 1 to enable and 0 to disable the service to start"
	    echo "[INFO] 7 bit masking represents service like hadoop (hive), zeppelin, kafka (schema registry), flink, spark, hbase, zookeeper"
	    echo "[INFO] For example, 'dfops start mask1001000' only start hadoop (hive) and spark service"
	fi
else
	echo "[ERROR] No service will start because of wrong command."
fi
}

stop_all_service () {
if [ "${service}" = "kafka" ]; then
	stop_confluent
	stop_zookeeper
	stop_hadoop
	stop_zeppelin
elif [ "${service}" = "default" ]; then
	stop_hadoop
	stop_zeppelin
elif [ "${service}" = "hive" ]; then
	stop_hadoop	
elif [ "${service}" = "all" ]; then
    stop_spark
	stop_flink
	stop_hbase
	stop_zookeeper
	stop_confluent
	stop_hadoop
	stop_zeppelin	
elif [ "${service}" = "spark" ]; then
	stop_spark	
	stop_hadoop
	stop_zeppelin
elif [ "${service}" = "hbase" ]; then
	stop_hbase
	stop_zookeeper
	stop_hadoop
	stop_zeppelin	
elif [ "${service}" = "flink" ]; then
	stop_flink	
	stop_hadoop
	stop_zeppelin	
else
	echo "[ERROR] No service will stop because of wrong command."
fi
}

restart_all_service () {
stop_all_service
start_all_service
}

status_all () {
    status ${ZOO_KEEPER_DAEMON_NAME} ZooKeeper
    status ${KAFKA_DAEMON_NAME} Kafka
    status ${KAFKA_CONNECT_DAEMON_NAME} Kafka_Connect
    status ${SCHEMA_REGISTRY_DAEMON_NAME} Schema_Registry
    status ${FLINK_JM_DAEMON_NAME} Flink_JobMgr
    status ${FLINK_TM_DAEMON_NAME} Flink_TaskMgr
    status ${SPARK_JM_DAEMON_NAME} Spark_Master
    status ${SPARK_TM_DAEMON_NAME} Spark_Worker
    status ${ZEPPELIN_DAEMON_NAME} Zeppelin_Server
    status ${HBASE_HMASTER_DAEMON_NAME} HBase_Master
    status ${HBASE_RSERVER_DAEMON_NAME} HBase_Region
    status ${HADOOP_NN_DAEMON_NAME} Hadoop_NameNode
    status ${HADOOP_DN_DAEMON_NAME} Hadoop_DataNode
    status ${YARN_RM_DAEMON_NAME} Yarn_ResourceMgr
    status ${YARN_NM_DAEMON_NAME} Yarn_NodeMgr
    status ${HIVE_SERVER_DAEMON_NAME} HiveServer2
    status ${HIVE_METADATA_NAME} HiveMetaStore
    status ${HIVE2_SERVER_DAEMON_NAME} Hive2Server2
    status ${HIVE2_METADATA_NAME} Hive2MetaStore   
}

if [ "${action}" = "start" ] ; then
	start_all_service
elif [ "${action}" = "stop" ]; then
	stop_all_service
elif [ "${action}" = "restart" ]; then
	restart_all_service
elif [ "${action}" = "status" ]; then
	status_all
elif [ "${action}" = "format" ]; then
	format_all
elif [ "${action}" = "help" ]; then
	usage
else
    echo "[ERROR] Wrong command entered."
    usage
fi
