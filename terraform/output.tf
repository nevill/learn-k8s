output "IPAddr" {
  value = "${virtualbox_vm.master.*.network_adapter.1.ipv4_address}"
}
