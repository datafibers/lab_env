#!/bin/bash
set -e

#install flags
install_java=true

install_hadoop=true
install_hive=true
install_confluent=false
install_flink=false
install_mongo=true
install_spark=true
install_livy=false
install_grafana=false
install_elastic=false
install_zeppelin=true
install_hbase=true
install_phoenix=true

#software repository links
file_name_hadoop=hadoop-2.6.0.tar.gz
dl_link_hadoop=https://archive.apache.org/dist/hadoop/common/hadoop-2.6.0/hadoop-2.6.0.tar.gz

file_name_hive=hive-1.2.1.tar.gz
dl_link_hive=https://archive.apache.org/dist/hive/hive-1.2.1/apache-hive-1.2.1-bin.tar.gz

file_name_confluent=confluent-3.3.0.tar.gz
dl_link_confluent=http://packages.confluent.io/archive/3.3/confluent-oss-3.3.0-2.11.tar.gz

file_name_flink=flink-1.3.2.tgz
dl_link_flink=http://www-us.apache.org/dist/flink/flink-1.3.2/flink-1.3.2-bin-hadoop26-scala_2.11.tgz

file_name_elastic=elastic-2.3.4.tar.gz
dl_link_elastic=https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch/2.3.4/elasticsearch-2.3.4.tar.gz

file_name_zeppelin=zeppelin-0.7.2.tgz
dl_link_zeppelin=https://archive.apache.org/dist/zeppelin/zeppelin-0.7.2/zeppelin-0.7.2-bin-all.tgz

file_name_grafana=grafana-4.6.2.tar.gz
dl_link_grafana=https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana-4.6.2.linux-x64.tar.gz

file_name_spark=spark-2.2.0.tgz
dl_link_spark=https://archive.apache.org/dist/spark/spark-2.2.0/spark-2.2.0-bin-hadoop2.6.tgz

file_name_hbase=hbase-1.3.0.tar.gz
dl_link_hbase=https://archive.apache.org/dist/hbase/1.3.0/hbase-1.3.0-bin.tar.gz

file_name_phoenix=apache-phoenix-4.13.1-HBase-1.3-bin.tar.gz
dl_link_phoenix=http://archive.apache.org/dist/phoenix/apache-phoenix-4.13.1-HBase-1.3/bin/apache-phoenix-4.13.1-HBase-1.3-bin.tar.gz

file_name_livy=livy-0.4.0.tar.gz
dl_link_livy=https://github.com/datafibers-community/df_demo/releases/download/livy/livy-0.4.0-incubating-bin.tar.gz

# sample call install_flag soft_install dl_link, such as
# soft_install $install_hadoop hadoop $dl_link_hadoop

function soft_install
{
    install_flag=${1:-false}
    install_soft_link=/opt/$2
    dl_link=$3
    file_name=$4

	if [ "$install_flag" = true ]; then

		case $file_name in
			(*.tar.gz) install_folder=/opt/`basename $file_name .tar.gz`;;
			(*.tar) install_folder=/opt/`basename $file_name .tar`;;
			(*.tgz) install_folder=/opt/`basename $file_name .tgz`;;
		esac
		
		echo "install_flag=$install_flag"
		echo "dl_link=$dl_link"
		echo "file_name=$file_name"
		echo "install_folder=$install_folder"
		echo "install_soft_link=$install_soft_link"

        if [ ! -e $install_folder ]; then
	    if [ ! -d /tmp/vagrant-downloads ]; then
               mkdir -p /tmp/vagrant-downloads
               sudo chmod a+rw /tmp/vagrant-downloads
	    fi
            cd /tmp/vagrant-downloads
            if [ ! -e $file_name ]; then
                wget --progress=bar:force -O $file_name $dl_link --no-check-certificate
            fi
            cd /opt/
            mkdir -p $install_folder && tar xf /tmp/vagrant-downloads/$file_name -C $install_folder
            ln -sfn $install_folder $install_soft_link
	    cd $install_soft_link
		# Following 3 steps mv all stuff from subfolder to upper folder and delete it
		mv * delete
		mv */* .
		rm -rf delete
        fi
		echo "completed installing ${2} with version ${file_name}"
    fi
}

# Setup install staging folders
if [ ! -d /tmp/vagrant-downloads ]; then
    mkdir -p /tmp/vagrant-downloads
fi
chmod a+rw /tmp/vagrant-downloads

chmod a+rw /opt

if [ ! -e /mnt ]; then
    mkdir /mnt
fi
chmod a+rwx /mnt

sudo apt-get -y update

# Install and configure Apache Hadoop
echo "install - hdp"
soft_install $install_hadoop hadoop $dl_link_hadoop $file_name_hadoop

# Install and configure Hive
soft_install $install_hive hive $dl_link_hive $file_name_hive

# Install CP
soft_install $install_confluent confluent $dl_link_confluent $file_name_confluent

# Install Elastic
soft_install $install_elastic elastic $dl_link_elastic $file_name_elastic

# Install Zeppelin
soft_install $install_zeppelin zeppelin $dl_link_zeppelin $file_name_zeppelin

# Install Flink
soft_install $install_flink flink $dl_link_flink $file_name_flink

# Install Spark
soft_install $install_spark spark $dl_link_spark $file_name_spark

# Install HBase
soft_install $install_hbase hbase $dl_link_hbase $file_name_hbase

# Install Phoenix
soft_install $install_phoenix phoenix $dl_link_phoenix $file_name_phoenix

# Install Livy
soft_install $install_livy livy $dl_link_livy $file_name_livy

# Install Grafana
soft_install $install_grafana grafana $dl_link_grafana $file_name_grafana

# Install MongoDB
if [ "$install_mongo" = true ]; then
    sudo rm -f /etc/apt/sources.list.d/mongodb*.list
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6
    echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.4.list
    sudo apt-get update
    sudo apt-get install -y mongodb-org

    sudo systemctl enable mongod.service
    sudo systemctl daemon-reload
fi

#Install Java 8
JAVA_VER=$(java -version 2>&1 | grep -i version | sed 's/.*version ".*\.\(.*\)\..*"/\1/; 1q')
if [ "$JAVA_VER" != "8" ] && [ "$install_java" = "true" ]; then
    echo "installing java 8 ..."
    cd /opt/
    wget --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u161-b12/2f38c3b165be4555a1fa6e98c45e0808/jdk-8u161-linux-x64.tar.gz
    tar -zxf jdk-8u161-linux-x64.tar.gz
    ln -sfn /opt/jdk1.8.0_161 /opt/jdk
    sudo update-alternatives --install /usr/bin/java java /opt/jdk/bin/java 8000
    sudo update-alternatives --install /usr/bin/javac javac /opt/jdk/bin/javac 8000
fi

#Install Maven and Git
sudo apt-get install -y maven git vim
sudo apt-get install dos2unix

# Convert all files to Linux in case git setting wrong in Win
find /vagrant/ -type f -print0 | xargs -0 dos2unix --

# Copy .profile and change owner to vagrant
cp /vagrant/.profile /home/vagrant/
chown vagrant:vagrant /home/vagrant/.profile
source /home/vagrant/.profile

cp -r /vagrant/etc /mnt/
chown -R vagrant:vagrant /mnt/etc
mkdir -p /mnt/logs
chown -R vagrant:vagrant /mnt/logs

mkdir -p /mnt/dfs/name
mkdir -p /mnt/dfs/data

chown -R vagrant:vagrant /mnt/dfs
chown -R vagrant:vagrant /mnt/dfs/name
chown -R vagrant:vagrant /mnt/dfs/data
sudo chown -R vagrant:vagrant /opt

# Map Flink Web Console port to 8001
if [ "$install_flink" = true ]; then
  mv /opt/flink/conf/flink-conf.yaml /opt/flink/conf/flink-conf.yaml.bk
  cp /mnt/etc/flink/flink-conf.yaml /opt/flink/conf/
fi

if [ "$install_mongo" = true ]; then
# Enable mongodb access from out side of vm
  sudo mv /etc/mongod.conf /etc/mongod.conf.bk
  cp /mnt/etc/mongo/mongod.conf /etc/
fi

if [ "$install_spark" = true ]; then
  cp /mnt/etc/hive/hive-site.xml /opt/spark/conf/
  cp /mnt/etc/spark/* /opt/spark/conf/
fi

if [ "$install_livy" = true ]; then
  cp /mnt/etc/livy/* /opt/livy/conf/
fi

# if [ "$install_phoenix" = true ] && [ "$install_hbase" = true ]; then
#  cp /opt/phoenix/*.jar /opt/hbase/lib/
# fi

# Install MySQL Metastore for Hive - do this after creating profiles in order to use hive schematool
sudo apt-get -y update
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password mypassword'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password mypassword'
sudo apt-get -y install mysql-server
sudo apt-get -y install libmysql-java

sudo ln -sfn /usr/share/java/mysql-connector-java.jar /opt/hive/lib/mysql-connector-java.jar

# Configure Hive Metastore
mysql -u root --password="mypassword" -f \
-e "DROP DATABASE IF EXISTS metastore;"

mysql -u root --password="mypassword" -f \
-e "CREATE DATABASE IF NOT EXISTS metastore;"

mysql -u root --password="mypassword" \
-e "GRANT ALL PRIVILEGES ON metastore.* TO 'hive'@'localhost' IDENTIFIED BY 'mypassword'; FLUSH PRIVILEGES;"

schematool -dbType mysql -initSchema

echo "***************************************************************************************"
echo "*Lab Virtual Machine Setup Completed.                                                 *"
echo "*SSH address:127.0.0.1:2222.                                                          *"
echo "*SSH username/password:vagrant/vagrant                                                *"
echo "*Command: ssh vagrant@localhost -p 2222                                               *"
echo "***************************************************************************************"
