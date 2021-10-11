source "vagrant" "basek8s" {
  add_force            = true
  box_name             = "basek8s"
  communicator         = "ssh"
  provider             = "virtualbox"
  source_path          = "ubuntu/focal64"
  teardown_method = "destroy"
  output_dir = "box"
}

build {
  sources = ["source.vagrant.basek8s"]

  provisioner "shell" {
    execute_command = "sudo {{ .Path }}"
    script = "install.sh"
  }
}
