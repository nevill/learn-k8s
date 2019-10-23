output "IPAddr" {
  value = "${virtualbox_vm.master.*.network_adapter.0.ipv4_address}"
}
