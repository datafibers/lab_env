#!/bin/bash
set -e

STARTTIME=$(date +%s)

. /vagrant/config/install_config.sh
. /vagrant/config/install_version.sh

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
                # wget --progress=bar:force -O $file_name $dl_link --no-check-certificate
                echo "Please wait, downloading ..."
                aria2c -x5 $dl_link -o $file_name
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
# Install download tool
sudo apt-get -y install aria2

# Install and configure Apache Hadoop
echo "install - hdp"
soft_install $install_hadoop hadoop $dl_link_hadoop $file_name_hadoop

# Install and configure Apache Tez
echo "install - tez"
soft_install $install_tez tez $dl_link_tez $file_name_tez

# Install and configure Hive
soft_install $install_hive hive $dl_link_hive $file_name_hive

# Install and configure Hive v2
soft_install $install_hive hive2 $dl_link_hive2 $file_name_hive2

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
MONGO_VERSION=$(mongo -version 2>&1 | grep -i version | sed 's/MongoDB shell version v//g'|head -1|cut -c1-3)
if [ "$MONGO_VERSION" != "3.4" ] && [ "$install_mongo" = true ]; then
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
    # wget --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" $dl_link_java
    aria2c -x5 --header="Cookie: oraclelicense=accept-securebackup-cookie" $dl_link_java
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

chown -R vagrant:vagrant /vagrant/scripts/*
chmod +x /vagrant/scripts/*
cp -r /vagrant/scripts/* /home/vagrant/

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
  sudo cp /mnt/etc/mongo/mongod.conf /etc/
fi

if [ "$install_spark" = true ]; then
  cp /mnt/etc/hive/hive-site.xml /opt/spark/conf/
  cp /mnt/etc/spark/* /opt/spark/conf/
fi

if [ "$install_livy" = true ]; then
  cp /mnt/etc/livy/* /opt/livy/conf/
fi

if [ "$install_phoenix" = true ] && [ "$install_hbase" = true ]; then
  cp /opt/phoenix/phoenix-*-server.jar /opt/hbase/lib/
  cp /mnt/etc/hbase/* /opt/hbase/conf/
fi

if [ "$install_zeppelin" = true ]; then
  cp /opt/hive/lib/hive-jdbc-*-standalone.jar /opt/zeppelin/interpreter/jdbc/
  cp /opt/hadoop/share/hadoop/common/hadoop-common-*.jar /opt/zeppelin/interpreter/jdbc/
fi

if [ "$install_hive" = true ]; then
    # Install MySQL Metastore for Hive - do this after creating profiles in order to use hive schematool
    sudo apt-get -y update
    sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password mypassword'
    sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password mypassword'
    sudo apt-get -y install mysql-server
    sudo apt-get -y install libmysql-java

    # Configure Hive Metastore
    mysql -u root --password="mypassword" -f \
    -e "DROP DATABASE IF EXISTS metastore;"

    mysql -u root --password="mypassword" -f \
    -e "CREATE DATABASE IF NOT EXISTS metastore;"

    mysql -u root --password="mypassword" \
    -e "GRANT ALL PRIVILEGES ON metastore.* TO 'hive'@'localhost' IDENTIFIED BY 'mypassword'; FLUSH PRIVILEGES;"

    ln -sfn /usr/share/java/mysql-connector-java.jar /opt/hive2/lib/mysql-connector-java.jar
    ln -sfn /usr/share/java/mysql-connector-java.jar /opt/hive/lib/mysql-connector-java.jar
    
    cp /mnt/etc/hive2/* /opt/hive2/conf/
    cp /mnt/etc/hive/* /opt/hive/conf/
    chown -R vagrant:vagrant /opt/hive/conf/*
    chown -R vagrant:vagrant /opt/hive2/conf/*
    
    /opt/hive2/bin/schematool -dbType mysql -initSchema
    echo "Init. schema using hive version 2"
fi

echo "Creating keys for passwordless ssh"
echo -e  'y' | ssh-keygen -t rsa -f /home/vagrant/.ssh/id_rsa -q -P ''
chmod 777 /home/vagrant/.ssh/authorized_keys
cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys

ENDTIME=$(date +%s)
echo "======================================================================>"
echo "=> The Lab Virtual Machine setup has completed in $((($ENDTIME - $STARTTIME)/60)) minutes $((($ENDTIME - $STARTTIME)%60)) seconds."
echo "=> SSH Command : ssh vagrant@localhost -p 2222"
echo "=> SSH Password: vagrant"
echo "======================================================================>"
