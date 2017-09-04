# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box 
  end

  config.vm.define :one_progress do |vb|
    vb.vm.box = "centos/7"
    vb.vm.network :private_network, ip: "192.168.33.10"

    vb.vm.provision "ansible" do |ansible|
      ansible.playbook       = "provisioning/playbook/site.yml"
      ansible.inventory_path = "provisioning/playbook/hosts"
      ansible.limit          = "staging"
    end
  end
end
