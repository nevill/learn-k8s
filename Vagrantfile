# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  num_of_instance = 3
  (1..num_of_instance).each do |i|
    name = i == 1 ? "primary" : "node%02d" % i
    config.vm.define name do |cfg|
      cfg.vm.hostname = name
      cfg.vm.box = "basek8s"
      cfg.vm.box_check_update = false

      addr = "192.168.34.%d" % (i + 1)
      cfg.vm.provision "shell",
        inline: "echo 'KUBELET_EXTRA_ARGS=\"--node-ip=#{addr}\"' | tee /etc/default/kubelet"

      if i == 1
        cfg.vm.provision "file", source: "kubeadm-init.yaml", destination: "$HOME/"
        memory = 6144
      else
        memory = 4096
      end

      cfg.vm.network "private_network",
        name: "vboxnet0",
        ip: addr

      cfg.vm.provider "virtualbox" do |vb|
        # 2 cores, 4 GiB memory
        vb.cpus = 2
        vb.memory = memory
      end
    end
  end
end
