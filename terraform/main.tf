variable "token" {
  default = "9qmcqb.egwk7yl4zowihycw"
}

resource "tls_private_key" "etcd" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "etcd" {
  key_algorithm     = "RSA"
  private_key_pem   = "${tls_private_key.etcd.private_key_pem}"
  is_ca_certificate = true

  subject {
    common_name         = "etcd-root-cert"
    organization        = "etcd"
    organizational_unit = "Personal"
    province            = "Shanghai"
    country             = "CHN"
  }

  validity_period_hours = 17520 # 2 years

  allowed_uses = [
    "cert_signing",
    "crl_signing",
  ]
}

resource "tls_private_key" "sa" {
  algorithm = "RSA"
}

resource "tls_private_key" "k8s" {
  algorithm = "RSA"
}

# to get ca-cert hash
# openssl x509 -in /etc/kubernetes/pki/ca.crt -noout -pubkey | grep -v "PUBLIC KEY" | base64 -d | sha256sum
resource "tls_self_signed_cert" "k8s" {
  key_algorithm     = "RSA"
  private_key_pem   = "${tls_private_key.k8s.private_key_pem}"
  is_ca_certificate = true

  subject {
    common_name         = "k8s-root-cert"
    organization        = "k8s"
    organizational_unit = "Personal"
    province            = "Shanghai"
    country             = "CHN"
  }

  validity_period_hours = 17520 # 2 years

  allowed_uses = [
    "cert_signing",
    "crl_signing",
  ]
}

resource "virtualbox_vm" "master" {
  count  = 3
  name   = "${format("master-%02d", count.index + 1)}"
  image  = "../iso/builds/virtualbox-centos7.box"
  cpus   = 2
  memory = "1.0 gib"

  network_adapter {
    type           = "hostonly"
    host_interface = "vboxnet1"
  }

  network_adapter {
    type = "nat"
  }

  connection {
    host     = "${self.network_adapter.0.ipv4_address}"
    type     = "ssh"
    user     = "root"
    password = "vagrant"
  }

  provisioner "remote-exec" {
    on_failure = "continue"

    inline = [
      "hostnamectl set-hostname ${self.name}",
    ]
  }

  provisioner "remote-exec" {
    on_failure = "continue"

    scripts = [
      "./modules/kubernetes/init.sh",
    ]
  }
}

data "template_file" "kubeadm_config" {
  template = "${file("./modules/kubernetes/kubeadm-config.yml")}"

  count  = length(virtualbox_vm.master.*.name)
  vars = {
    token        = "${var.token}"
    api_endpoint = "${element(virtualbox_vm.master.*.network_adapter.0.ipv4_address, 0)}"
    host_ip      = "${element(virtualbox_vm.master.*.network_adapter.0.ipv4_address, count.index)}"
    host_name    = "${element(virtualbox_vm.master.*.name, count.index)}"

    state = "new"

    etcd_cluster = "${
      join(
        ",",
        formatlist(
          "%s=https://%s:2380",
          virtualbox_vm.master.*.name,
          virtualbox_vm.master.*.network_adapter.0.ipv4_address
        )
      )
    }"
  }
}

resource "local_file" "kubeadm_config" {
  depends_on = [
    "virtualbox_vm.master",
  ]

  count    = "${length(virtualbox_vm.master.*.name)}"
  content  = "${element(data.template_file.kubeadm_config.*.rendered, count.index)}"
  filename = "${path.root}/files/kubeadm-config-${count.index + 1}.yml"
}

data "template_file" "init_k8s_master" {
  template = "${file("./modules/kubernetes/init-master.sh")}"

  vars = {
    etcd_ca_crt    = "${tls_self_signed_cert.etcd.cert_pem}"
    etcd_ca_key    = "${tls_private_key.etcd.private_key_pem}"
    sa_private_key = "${tls_private_key.sa.private_key_pem}"
    sa_public_key  = "${tls_private_key.sa.public_key_pem}"
    k8s_ca_crt     = "${tls_self_signed_cert.k8s.cert_pem}"
    k8s_ca_key     = "${tls_private_key.k8s.private_key_pem}"
  }
}

resource "local_file" "init_k8s_master" {
  count    = "${length(virtualbox_vm.master.*.name)}"
  content  = "${element(data.template_file.init_k8s_master.*.rendered, count.index)}"
  filename = "${path.root}/files/init-master-${count.index + 1}.sh"
}

resource "null_resource" "init_k8s_master" {
  count = "${length(virtualbox_vm.master.*.name)}"

  connection {
    type     = "ssh"
    user     = "root"
    password = "vagrant"
    host     = "${element(virtualbox_vm.master.*.network_adapter.0.ipv4_address, count.index)}"
  }

  provisioner "file" {
    source      = "${element(local_file.kubeadm_config.*.filename, count.index)}"
    destination = "/root/kubeadm-config.yml"
  }

  provisioner "remote-exec" {
    on_failure = "continue"

    scripts = [
      "${element(local_file.init_k8s_master.*.filename, count.index)}",
    ]
  }
}

resource "null_resource" "cluster" {
  depends_on = [
    "null_resource.init_k8s_master",
  ]

  connection {
    type     = "ssh"
    user     = "root"
    password = "vagrant"
    host     = "${element(virtualbox_vm.master.*.network_adapter.0.ipv4_address, 0)}"
  }

  provisioner "file" {
    source      = "./modules/kubernetes/kuberouter.yml"
    destination = "/root/kuberouter.yml"
  }

  provisioner "remote-exec" {
    on_failure = "continue"

    inline = [
      "mkdir ~/.kube && cp /etc/kubernetes/admin.conf ~/.kube/config",
      "kubectl apply -f kuberouter.yml",
    ]
  }
}

resource "virtualbox_vm" "node" {
  depends_on = [
    "null_resource.cluster",
  ]

  count  = 1
  name   = "${format("node-%02d", count.index + 1)}"
  image  = "./iso/builds/virtualbox-centos7.box"
  cpus   = 2
  memory = "1.0 gib"

  network_adapter {
    type           = "hostonly"
    host_interface = "vboxnet1"
  }

  network_adapter {
    type = "nat"
  }

  connection {
    host     = "${self.network_adapter.0.ipv4_address}"
    type     = "ssh"
    user     = "root"
    password = "vagrant"
  }

  provisioner "remote-exec" {
    on_failure = "continue"

    inline = [
      "hostnamectl set-hostname ${self.name}",
    ]
  }

  provisioner "remote-exec" {
    on_failure = "continue"

    scripts = [
      "./modules/kubernetes/init.sh",
    ]
  }
}

resource "null_resource" "init_k8s_node" {
  connection {
    type     = "ssh"
    user     = "root"
    password = "vagrant"
    host     = "${element(virtualbox_vm.node.*.network_adapter.0.ipv4_address, 0)}"
  }

  provisioner "remote-exec" {
    on_failure = "continue"

    inline = [
      "kubeadm join ${element(virtualbox_vm.master.*.network_adapter.0.ipv4_address, 0)}:6443 --token ${var.token}  --discovery-token-unsafe-skip-ca-verification",
    ]
  }
}
