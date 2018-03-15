# Overview
This is very lightweighted vagrant image for Hadoop big data training. The total memory needed is only 4G (450M left after all service are started).

## Soft Installed
This distribution is packaged according to the [HDP 2.6.4](https://docs.hortonworks.com/HDPDocuments/HDP2/HDP-2.6.4/bk_release-notes/content/comp_versions.html).
* apache-phoenix-4.13.1-HBase-1.1-bin/
* confluent-3.3.0/
* flink-1.3.2/
* hadoop-2.7.3/
* hbase-1.1.2/
* hive-1.2.1/
* spark-2.2.0/
* zeppelin-0.7.3/

## Quick Setup
1. Install [Oracle VirtualBox](https://www.virtualbox.org/wiki/Downloads)
2. Install [Vagrant](https://www.vagrantup.com/downloads.html)
3. Go to a proper folder and git clone this repository ```git clone https://github.com/datafibers/lab_env.git```
4. To install ```cd lab_env && vagrant up```
5. To update ```cd lan_env && git pull && vagrant provision```

## Operation Command (in VM)
* Enter ```ops``` to get full command help
* Enter ```ops start all``` to start all service
* Enter ```ops status``` to check status as follows
```
vagrant@vagrant:~$ ops status
****************Starting Operations****************
[INFO]   [ZooKeeper]          is running at [3232]
[INFO]   [Kafka]              is running at [3302]
[INFO]   [Kafka_Connect]      is running at [3464]
[INFO]   [Schema_Registry]    is running at [3387]
[INFO]   [Flink_JobMgr]       is running at [4298]
[INFO]   [Flink_TaskMgr]      is running at [4644]
[INFO]   [Spark_Master]       is running at [4702]
[INFO]   [Spark_Worker]       is running at [4926]
[INFO]   [Zeppelin_Server]    is running at [5060]
[INFO]   [HBase_Master]       is running at [3658]
[INFO]   [HBase_Region]       is running at [3777]
[INFO]   [Hadoop_NameNode]    is running at [2131]
[INFO]   [Hadoop_DataNode]    is running at [2251]
[INFO]   [Yarn_ResourceMgr]   is running at [2615]
[INFO]   [Yarn_NodeMgr]       is running at [2737]
[INFO]   [HiveServer2]        is running at [2953]
[INFO]   [HiveMetaStore]      is running at [2952]
```
## Vagrant Command Reference (outside VM)
* Start the vm/image install
```
vagrant up
```
* Stop the vm
```
vagrant halt
```
* Update the vm
```
git pull && vagrant provision
```
* Suspend the vm
```
vagrant suspend
```
* Wake up the vm
```
vagrant resume
```
* Restart the vm
```
vagrant reload
```
