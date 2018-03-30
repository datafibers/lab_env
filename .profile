# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

export LAB_HOME="/home/vagrant"
export JAVA_HOME="/opt/jdk"

export HADOOP_USER_CLASSPATH_FIRST=true
export HADOOP_CONF_DIR="/mnt/etc/hadoop"
export HADOOP_LOG_DIR="/mnt/logs"
# export HIVE_CONF_DIR="/mnt/etc/hive2"
export HADOOP_HOME="/opt/hadoop"
# export HIVE_HOME="/opt/hive2" # in order to run two version of hive, have to comment it out and use in hive-env.sh since setting her has the highest privilige
export CONFLUENT_HOME="/opt/confluent"
export FLINK_HOME="/opt/flink"
export SPARK_HOME="/opt/spark"
export HBASE_HOME="/opt/hbase"
export ZEPPELIN_HOME="/opt/zeppelin"
export PHOENIX_HOME="/opt/phoenix"

PATH="$HADOOP_HOME/bin:$PATH"
PATH="$HADOOP_HOME/sbin:$PATH"
# PATH="$HIVE_HOME/bin:$PATH"
PATH="$CONFLUENT_HOME/bin:$PATH"
PATH="$FLINK_HOME/bin:$PATH"
PATH="$SPARK_HOME/bin:$PATH"
PATH="$SPARK_HOME/sbin:$PATH"
PATH="$HBASE_HOME/bin:$PATH"
PATH="$PHOENIX_HOME/bin:$PATH"
PATH="$ZEPPELIN_HOME/bin:$PATH"
PATH="$JAVA_HOME/bin:$PATH"
PATH="$LAB_HOME:$PATH"

alias ops='ops.sh'
alias bee='bee.sh'

