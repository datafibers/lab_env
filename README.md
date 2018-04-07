# Overview
This is very lightweighted vagrant image for Hadoop big data lab. The total memory needed is only 5G (450M left after all service are started). It will take around 15 minutes to download and setup.

## Soft Installed
This distribution is compatible with [HDP 2.6.4](https://docs.hortonworks.com/HDPDocuments/HDP2/HDP-2.6.4/bk_release-notes/content/comp_versions.html), besides upgrade hive and hadoop to stable version.

| Hadooper      | Stream          | Visualization  | Utility |
| ------------- |-----------------| ---------------|---------|
| hadoop-2.7.5  | flink-1.3.2     | grafana-5.0.3  | git     |
| hive-1.2.2    | spark-2.2.0     | zeppelin-0.7.3 | mysql   |
| hive-2.3.2    | confluent-3.3.0 |                | maven   |
| hbase-1.2.2   |                 |                | dos2unix|
| phoenix-4.13.2|                 |                | aria2   |
| tez-0.9.1     |                 |                |         |

## Quick Setup
1. Install [Oracle VirtualBox](https://www.virtualbox.org/wiki/Downloads)
1. Install [Vagrant](https://www.vagrantup.com/downloads.html)
1. Go to a proper folder and git clone this repository ```git clone https://github.com/datafibers/lab_env.git```
1. If you prefer to install specific configuration from [branch](https://github.com/datafibers/lab_env/branches), ```git checkout <branch_name>```
1. If you prefer to customize install config, you can modify [conf/install_config.sh](https://github.com/datafibers/lab_env/blob/master/config/install_config.sh) or [install_version.sh](https://github.com/datafibers/lab_env/blob/master/config/install_version.sh)
1. To install ```cd lab_env && vagrant up```
1. After installed, you'll need to run ```ops format``` to format hadoop for the very first time.
1. To update ```cd lan_env && git pull && vagrant provision```

## Operation Command Reference (Run inside VM)
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
[INFO]   [Hive2Server2]       is running at [2954]
[INFO]   [Hive2MetaStore]     is running at [2955]
```

## Tool Command Reference (Run inside VM)
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
* Browse http://localhost:8088 to check Yarn Application Master
* Browse http://localhost:8042 to check Yarn Node Manager
* Browse http://localhost:16010 to check HBase Master

## Vagrant Command Reference (Run outside VM)
| Purpose                    | Command         | 
| -------------------------- |-----------------| 
| Start the vm/image install | ```vagrant up```|
| Stop the vm                | ```vagrant halt```|
| Update the vm              | ```git pull && vagrant provision``` |
| Suspend the vm/hibernate   | ```vagrant suspend```|
| Wake up the vm             | ```vagrant resume```|
| Restart the vm             | ```vagrant reload```|

## Known Issues
* If the start up requires password, please do following setting.
```
ssh-keygen -t rsa -P ''
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```
* To re-associate the vagrant and virtualbox at [here](https://gist.github.com/datafibers/bd6aec4cfd3fcbbc68f5b6379c1ef2fd)
* When vagrant provision has SSH authtication issues, add following in the Vagrantfile.
```
config.ssh.username = "vagrant"  
config.ssh.password = "vagrant"  
config.ssh.insert_key = false
```
