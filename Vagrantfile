# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

ETCD_DISCOVERY_URL = "https://discovery.etcd.io/839382947dc86deba05e2894723e98e7"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    ### Define options for all VMs ###
    # Using vagrant-cachier improves performance if you run repeated yum/apt updates
    if defined? VagrantPlugins::Cachier
      config.cache.auto_detect = true
    end
    config.ssh.forward_agent = true

    # distro-agnostic puppet install script from https://github.com/danieldreier/puppet-installer
#    config.vm.provision "shell", inline: "curl getpuppet.whilefork.com | bash"
    config.vm.provision "shell",
      inline: "if ls /vagrant/pkg/danieldreier-trigger-*.tar.gz ; then puppet module install /vagrant/pkg/danieldreier-trigger-*.tar.gz; fi"
    config.vm.provision "shell",
      inline: "rm -rf /etc/puppet/modules/trigger"
    config.vm.provision "shell",
      inline: "ln -s /vagrant /etc/puppet/modules/trigger"
    config.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "512", "--cpus", "4", "--ioapic", "on"]
    end
    config.vm.box = 'puppetlabs/debian-7.6-64-puppet'

    config.vm.define :server1 do |node|
      node.vm.hostname = 'server1.boxnet'
      node.vm.network :private_network, :auto_network => true

      # nuke the discovery cluster when we start to clear out previous nodes
      node.vm.provision "shell",
        inline: "curl -XDELETE #{ETCD_DISCOVERY_URL}/_state"
      node.vm.provision "shell",
        inline: "FACTER_etcd_discovery_url=#{ETCD_DISCOVERY_URL} puppet apply /vagrant/tests/install_etcd_with_watch.pp"
    end

    config.vm.define :server2 do |node|
      node.vm.hostname = 'server2.boxnet'
      node.vm.network :private_network, :auto_network => true
      node.vm.provision "shell",
        inline: "FACTER_etcd_discovery_url=#{ETCD_DISCOVERY_URL} puppet apply /vagrant/tests/install_etcd_with_watch.pp"
    end
    config.vm.define :server3 do |node|
      node.vm.hostname = 'server3.boxnet'
      node.vm.network :private_network, :auto_network => true
      node.vm.provision "shell",
        inline: "FACTER_etcd_discovery_url=#{ETCD_DISCOVERY_URL} puppet apply /vagrant/tests/install_etcd_with_watch.pp"
    end
end
