# -*- mode: ruby -*-
# vi: set ft=ruby :

REMOTE_SSH_PORT           = 12222
LOCAL_SSH_PORT            = 12222
FIRST_PROVISIONING_OUTPUT = "provisioning/playbook/group_vars/production.yml"

class Plugin < Vagrant.plugin('2')
  name 'create switch file'
  action_hook :create_switch_file, :provisioner_run do |hook|
    hook.after(
      :run_provisioner,
      lambda do |env|
        return unless env[:provisioner_name] == :shell

        File.open(FIRST_PROVISIONING_OUTPUT,"w") do |f| 
          f.puts("ansible_ssh_port: #{REMOTE_SSH_PORT}")
        end
        p "SELinuxの設定を変更しました。\'vagrant reload\'コマンドを実行してください。"
      end
    )
  end
end

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

    if File.exists?(FIRST_PROVISIONING_OUTPUT)
      vb.ssh.port = LOCAL_SSH_PORT
      vb.vm.network "forwarded_port", guest: REMOTE_SSH_PORT, host: LOCAL_SSH_PORT, host_ip: "127.0.0.1", id: "ssh"
    end

    vb.vm.provision "ansible" do |ansible|
      ansible.playbook       = "provisioning/playbook/site.yml"
      ansible.inventory_path = "provisioning/playbook/hosts"
      ansible.limit          = "staging"
    end

    # 初回起動時にだけ必要なプロビジョニング
    unless File.exists?(FIRST_PROVISIONING_OUTPUT)
      vb.vm.provision "shell", path: "provisioning/run_once.sh", args: REMOTE_SSH_PORT     
    end
  end
end
