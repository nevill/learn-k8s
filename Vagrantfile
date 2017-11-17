# -*- mode: ruby -*-

Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
  config.vm.provider :virtualbox do |vb|
    vb.memory = 2048
    vb.cpus = 2
  end

  config.vm.provision "ansible_local" do |ansible|
    ansible.playbook = "playbook.yml"
  end
end
