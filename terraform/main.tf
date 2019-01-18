resource "virtualbox_vm" "node" {
  count  = 2
  name   = "${format("node-%02d", count.index+1)}"
  image  = "./iso/builds/virtualbox-centos7.box"
  cpus   = 2
  memory = "512mib"

  network_adapter = [
    {
      type = "nat"
    },
    {
      type           = "hostonly"
      host_interface = "vboxnet1"
    },
  ]
}

output "IPAddr" {
  value = "${virtualbox_vm.node.*.network_adapter.1.ipv4_address}"
}
