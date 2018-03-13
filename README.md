
## Soft Installed
This distribution is packaged according to the [HDP 2.6.4](https://docs.hortonworks.com/HDPDocuments/HDP2/HDP-2.6.4/bk_release-notes/content/comp_versions.html).
* apache-phoenix-4.13.1-HBase-1.3-bin/
* confluent-3.3.0/
* flink-1.3.2/
* hadoop-2.7.3/
* hbase-1.1.2/
* hive-1.2.1/
* spark-2.2.0/
* zeppelin-0.7.3/
## Operation Command (in VM)
```
ops
```
## VM Command Help
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
