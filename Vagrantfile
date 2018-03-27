# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define "deb" do |deb|
    deb.vm.box = "bento/ubuntu-16.04"
    config.vm.provider 'virtualbox' do |vb|
      vb.customize ['modifyvm', :id, '--cableconnected1', 'on']
    end
    deb.vm.provision "shell", path: "vagrant_shell/deb.sh"
  end

  #Below does not work on billkitchen on windows
  #config.vm.synced_folder "~/.gnupg", "/root/.gnupg", owner: "root", group: "root"

  #Config port forward
  config.vm.network "forwarded_port", guest: 3000, host: 3000   #Grafana
  config.vm.network "forwarded_port", guest: 2181, host: 2181   #Zookeeper 
  config.vm.network "forwarded_port", guest: 6123, host: 6123   #Flink Resource Mgr.
  config.vm.network "forwarded_port", guest: 8001, host: 8001   #Flink Web Console  
  config.vm.network "forwarded_port", guest: 8080, host: 8080   #Zeppelin
  config.vm.network "forwarded_port", guest: 8081, host: 8002   #Flink/Kafka Schema Registry
  config.vm.network "forwarded_port", guest: 8082, host: 8082   #Kafka REST 
  config.vm.network "forwarded_port", guest: 8083, host: 8083   #Kafka Connect REST
  config.vm.network "forwarded_port", guest: 8998, host: 8998   #Livy
  config.vm.network "forwarded_port", guest: 9092, host: 9080   #Spark Master Web UI 
  config.vm.network "forwarded_port", guest: 9092, host: 9092   #Kafka  
  config.vm.network "forwarded_port", guest: 9200, host: 9200   #Elastic
  config.vm.network "forwarded_port", guest: 27017, host: 27017 #MongoDB
  config.vm.network "forwarded_port", guest: 27017, host: 60010 #HBase Master Web UI


  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", "4096"]
    vb.name = "BIG_DATA_LAB"
  end

  config.vm.provision "fix-no-tty", type: "shell" do |s|
      s.privileged = false
      s.inline = "sudo sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile"
  end

end
