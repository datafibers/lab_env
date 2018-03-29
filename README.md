# Overview
This is very lightweighted vagrant image for Hadoop big data lab. The total memory needed is only 4G (450M left after all service are started). It will take around 15 minutes to download and setup.

## Soft Installed
This distribution is compatible with [HDP 2.6.4](https://docs.hortonworks.com/HDPDocuments/HDP2/HDP-2.6.4/bk_release-notes/content/comp_versions.html), besides upgrade hive 2 to 2.3.
* apache-phoenix-4.13.1-HBase-1.1-bin/
* confluent-3.3.0/
* flink-1.3.2/
* hadoop-2.7.3/
* hbase-1.1.2/
* hive-1.2.1/
* hive-2.3.2/
* spark-2.2.0/
* zeppelin-0.7.3/
* mongodb-3.4
* grafana-5.0.3
* mysql-latest
* maven-latest
* git-latest
* dos2unix-latest

## Quick Setup
1. Install [Oracle VirtualBox](https://www.virtualbox.org/wiki/Downloads)
2. Install [Vagrant](https://www.vagrantup.com/downloads.html)
3. Go to a proper folder and git clone this repository ```git clone https://github.com/datafibers/lab_env.git```
4. To install ```cd lab_env && vagrant up```
5. To update ```cd lan_env && git pull && vagrant provision```
6. To install specific config, you can modify the ```conf/install_config.sh``` or ```conf/install_version.sh``` before ```vagrant up```
7. To install specific config from branch, ```git checkout <branch_name>```, then ```vagrant up```

## Known Issues
* When vagrant up is hanging there (connection timeout) for the first time installation. Check if you running VM has network connection option choose.
* After installed, you'll need to run ```ops format``` to format hadoop for the very first time.

## Operation Command Reference (in VM)
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

## Tool Command Reference (in VM)
* Enter ```mongo``` to connect to mongodb
* Enter ```mysql -u root --password="mypassword"``` to connect to mysql
* Enter ```beeline -u jdbc:hive2://localhost:10000/``` to connect to hive1
* Enter ```beeline -u jdbc:hive2://localhost:10500/``` to connect to hive2
* Enter ```spark-sql``` to use spark sql shell
* Enter ```spark-shell``` to use spark scala shell
* Enter ```pyspark``` to use spark python shell
* Enter ```hbase shell``` to use hbase shell
* Enter ```sqlline.py localhost``` to use phoenix shell
* Browse http://localhost:8080 to use zeppelin
* Browse http://localhost:8001 to use flink web console
* Browse http://localhost:3000 to use grafana

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
